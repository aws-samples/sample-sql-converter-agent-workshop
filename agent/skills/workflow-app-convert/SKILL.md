---
name: workflow-app-convert
description: Line-preserving Oracle→PostgreSQL conversion of embedded SQL in application source (Java, MyBatis XML, Python, etc.). Use when the user asks "convert this project", "apply conversions", "この SQL を変換して". SCAW2.0 版 — LLM呼び出しはMCPツール内部ではなくエージェント自身が担う構成。app-inventory.csv（assess phaseの産物）には依存しない。
---

# Application Source Convert（SCAW2.0版）

アプリケーションソースコードに埋め込まれたOracle SQLをPostgreSQLに変換する。
app worker（`scaw-migration-app`）が担当する。行保存（line-preserving）の
方針を維持する: SQL文字列リテラルの内容だけを変更し、周囲の制御構造・
変数宣言・文字列連結演算子は一切変更しない。

SCAW2.0はassess phaseを実装しないため、ソーススキャンから直接、対話の中で
1ファイル・1フラグメントずつ変換を進める。行保存・バインド整合性等の
CRITICAL制約はこのSKILL.mdに統合している。

## この skill を使う場面

- 「このプロジェクトのSQLを変換して」
- 「このファイルのこのSQLを変換して」
- 「残りのファイルも全部変換して」（後半の一括変換）

db trackのDBオブジェクト変換には使わない（`workflow-db-convert`を使う）。

## ワークフロー（対話的1件変換）

```
1. [scan_for_sql_files]
   プロジェクトルートをwalkし、SQL含む可能性のあるファイルをindexする
   （拡張子 + ヒューリスティック）。大規模プロジェクト（1000ファイル超）
   の場合はlarge_scale_warningが立つので、参加者に確認する。

2. [detect_xml_sql / 埋め込みSQL検出]
   MyBatis XML mapper等からSQL文を抽出する（動的タグ<if>/<choose>等対応）。
   .java/.py等のホスト言語ファイルの場合は、ファイル内容から直接SQL
   フラグメントの位置を特定する（対話的に行う。opengrepのようなAST的
   検出はSCAW2.0では実装しないため、エージェントがファイルを読んで判断
   する）。

3. [convert_oracle_sql_rules]
   決定的ルール変換を試行する（NVL→COALESCE等）。

4. [LLM変換ループ] — エージェント自身が下記「CRITICAL制約」に従って実行
   a. 下記の制約に従い、SQL文字列リテラルの内容だけを変換した
      converted_lines と、正規化されたPostgreSQL SQL（extracted_sql）を
      生成する
   b. MCPツール validate_pg_sql で extracted_sql を検証
   c. MCPツール validate_bind_integrity で、元のSQLと変換後SQLの
      プレースホルダ総数が変わっていないか検証（不一致はリトライしない
      — manual_review_bind扱いとする、詳細は下記）
   d. NG → 検証結果を見て、エージェントが再度変換を試行する（最大3回程度）
   e. OK → 5へ

5. [簡易実行テスト]（agent/mcpserver/ 再利用）
   db trackと同様、変換後SQLをOracle DatabaseとAurora PostgreSQLで
   実際に動かして精度を高める。extracted_sqlはプレースホルダを`$1..$n`に
   正規化したビューなので、以下の前段処理を行う:
   a. プレースホルダに妥当なテスト値をエージェント自身が判断して補い、
      Oracle用・PostgreSQL用それぞれの実行可能な完全なSQL文を組み立てる
      （決定的なダミー値生成ツールは実装しない。SELECTなら適切なWHERE値、
      INSERT/UPDATEなら型に合った値を判断する）。
   b. 対象テーブル・テストデータが既存スキーマ（`SCHEMA_SAMPLE`等）に
      存在しない場合、run_ora_sql / run_postgres_sqlでOracle/PostgreSQL
      両方にテスト用の一時テーブルとテストデータを作成する。
   c. run_ora_sql / run_postgres_sqlで実行し、結果を確認する
      （SELECT系は結果セットの比較、INSERT/UPDATE/DELETE系は実行成否と
      影響行数で判断。完全な結果一致が難しい場合は、意味的に同等かを
      エージェントが判断する）。
   d. 手順bで一時オブジェクトを作成した場合、テスト完了後に必ず削除する
      （DROP TABLE等）。
   e. NG（実行エラー、結果不一致）→ 変換ループ（手順4）に戻って再試行する。

6. [write_app_convert_outputs]
   mode（diff/patch/inplace）に応じてdiff/patch形式で出力する。

7. [write_skill_draft]（前半の対話的変換時のみ）
   発見した変換パターンを workshop-custom-rules/SKILL.md への追記案として
   エージェントが提示する。参加者がレビュー・編集する。
```

## CRITICAL制約（必ず守る）

ルールが競合する場合の優先順位: 制約1（バインド整合性）が全てに優先する
— バインド数を変える書き換えが必要な場合は、より綺麗なSQLが書けても
`skip_retry: true`とする。制約9（XML整形式）は制約5（リテラル内容のみ
変更）に優先する。迷ったら`skip_retry: true`を選ぶ。

1. **バインドパラメータの整合性**（最優先。この違反はリトライしない）:
   - `converted_lines`は元のホスト言語プレースホルダ方式をバイト単位で
     維持する。これはDBプレースホルダ（JDBC `?`、Oracle `:name`、MyBatis
     `#{name}` / `${name}`、PostgreSQL `$1..$n`、Python `%s` /
     `%(name)s`）と、ホスト言語の文字列補間（Python `{year}`、Java
     `String.format`、JS/TSテンプレートリテラル`${expr}`、C# `$"{expr}"`、
     PHP `"$var"`、VB.NET `{0}`）の両方を含む。
   - `extracted_sql`は正規化されたPostgreSQLビュー: 全プレースホルダを
     左から`$1..$n`に振り直す。これは`validate_pg_sql`・人間レビュー用の
     参考情報であり、実際にソースへパッチされるテキストではない。
   - プレースホルダの**総数**は変換前後で一致しなければならない
     （`validate_bind_integrity`が検証）。一致しない場合、ホスト側の
     バインドコード（`stmt.setInt(...)`等）の変更が必要になり、これは
     行保存変換の範囲外 — `SYSDATE`を新しいプレースホルダに置き換える
     ような操作は絶対にしない（`aws_oracle_ext.sysdate()`や
     `CURRENT_TIMESTAMP`を直接書く）。
   - **よくある落とし穴（ROWNUMページネーション）**: 詳細は
     `tool-app-inventory-schema`参照。各プレースホルダが1回だけ現れる
     形（`WITH ranked AS (...) SELECT * FROM ranked WHERE rn BETWEEN
     :startRow AND :endRow`）に変換する。
   - ホスト側のバインド呼び出し（`stmt.setInt(1, …)`等）は絶対に変更
     しない。
   - 自然なPostgreSQL書き換えがプレースホルダ数を変える場合は
     `skip_retry: true`とする。
2. **制御構造の保持**: プログラミング言語の構文（メソッド呼び出し、
   変数宣言、if/for/while、括弧）は変更しない。SQL文字列リテラルの
   内容だけが変わる。
3. **インデントの保持**: 各行の元の先頭空白を保つ。
4. **文字列連結の保持**: `+`、`&`、`||`、`.append()`、テンプレートリテラル
   の埋め込み等はそのまま維持する。変換後SQLの長さが変わる場合も、既存の
   連結構造の中で再配分する — 連結演算子や`.append(...)`呼び出しの個数を
   変えるような追加・削除はしない。
5. **SQLリテラルの内容だけが変わる**（制約9のXML例外あり）。周囲のコード
   （引用符自体を含む）は元の行レイアウトと一致させる。
6. **SQL以外の行には触れない**（`stmt.setInt(...)`、
   `stmt.executeUpdate()`、変数宣言、return、loop等）。バイト単位で
   `converted_lines`に同一のまま残す。SQL変換でバインド数が減っても、
   `stmt.setXxx(...)`呼び出しを削除・変更してはならない（制約1参照）。
7. **行数は厳密には保持しない**が、できるだけ元の範囲に近づける。
   `CONNECT BY`を`WITH RECURSIVE`に展開して数行増えるのは許容範囲。
   空の「パディング」行を追加したり、可読性を犠牲にして1行に圧縮したり
   しない。構造的な妥当な範囲に収まらない場合は`skip_retry: true`とする。
8. **SQLが短くなる場合**: 内容を均等に再配分する。空の`""` /
   `.append("")`パディングは禁止。
9. **XMLホストファイル（`.xml`、MyBatis mapper等）— 制約5に優先**:
   ファイルはwell-formedなXMLを維持する。SQL内の`<`、`>`、`&`は
   `&lt;`、`&gt;`、`&amp;`として出力する。元のファイルが既にこれらの
   エンティティを使っていた場合はそのまま維持する — 生の文字に戻さない
   （`validate_xml_escapes`相当の目視確認をエージェントが行う）。
   `<![CDATA[ ... ]]>`で囲む方式も許容する。MyBatisの動的タグ
   （`<if>`, `<choose>`, `<foreach>`等）とパラメータプレースホルダ
   （`#{x}`, `${x}`）はそのまま残す。
10. **範囲外の編集はしない**: `converted_lines`は
    `source_lines[start_line-1:end_line]`の置き換えとしてのみ解釈される。
    その範囲外の変更（import追加、helperメソッド新設等）が必要な場合は、
    `skip_retry: true` + `skip_reason`で人間へのフォローアップを示す。

## Pro*C（実験的機能、`.pc`ファイル）

Pro*Cファイルは別の判断ラダーを使う（`domain-proc-to-ecpg`参照）。
`detect_proc_sql`で検出したconstructのうち、SQLDA Method-4・`FOR :n`
ホスト配列・埋め込みPL/SQL・`EXEC ORACLE`オプション等は人間レビューに
回す。それ以外はルール変換（`COMMIT WORK RELEASE` →
`COMMIT; DISCONNECT ALL;`等）を試み、残りをLLM変換に回す。検証には
`validate_ecpg`（ラッパー構文）と`validate_pg_sql`（サーバー側SQL）の
両方を使う。`converted_lines`は完全な`EXEC SQL`文のまま保つこと。

## LLM出力の形（対話の中でエージェントが internally 保持する形）

```json
{
  "start_line": 10,
  "end_line": 17,
  "converted_lines": [
    "String q = \"SELECT COALESCE(name, 'x') FROM users\\n\"",
    "            + \"WHERE status = ?\";\n"
  ],
  "extracted_sql": "SELECT COALESCE(name, 'x') FROM users WHERE status = ?",
  "skip_retry": false,
  "skip_reason": ""
}
```

`skip_retry: true`の場合、`source_lines`をそのまま`converted_lines`として
返し、`extracted_sql`は空にする。理由（`skip_reason`）は「JPQL/HQL/ORM/
framework dialect」のような言及があれば`orm_delegated`、「pglast false
positive/valid PG/not a SQL identifier」のような言及があれば
`validator_limitation`、それ以外は`manual_review_range`として扱う。

## Review Status 語彙

`tool-app-inventory-schema`参照。

## プロジェクト固有ルール（workshop-custom-rules）

変換を始める前に`load_custom_rules(project_root=<dir>)`を呼び、
`workshop-custom-rules/SKILL.md`の内容を確認する。db trackと同様、
固定的な優先順位（どちらかが常に優先、というルール）は設けない。

## Related skills

- [workflow-db-convert](../workflow-db-convert/SKILL.md) — db trackオブジェクトの変換
- [domain-conversion-rules](../domain-conversion-rules/SKILL.md) — Oracle→PostgreSQL変換ルール一覧
- [domain-proc-to-ecpg](../domain-proc-to-ecpg/SKILL.md) — Pro*C（実験的機能）
- [tool-app-inventory-schema](../tool-app-inventory-schema/SKILL.md) — Classification / review status語彙
- [tool-output-layout](../tool-output-layout/SKILL.md) — 出力ファイルの配置
