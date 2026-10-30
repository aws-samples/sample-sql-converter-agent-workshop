---
name: tool-output-layout
description: Directory and filename map of every artefact SCAW2.0's convert phase emits — db track `./result/<object>/`, app track diff/patch, and `workshop-custom-rules/SKILL.md`. Use when the user asks "what's in this directory?", "what file should I look at?", "出力ファイルの意味を教えて". SCAW2.0 has no assess/report phase, so the large CSV inventory / narrative report layout is not used here.
---

# SCAW2.0 Output Layout

Map of every file SCAW2.0's convert-phase tools write. SCAW2.0はconvertの
みを実装するため（assess/convert/report各フェーズに分かれた多数の
`.tmp/` / `.cache/` / `.logs/` サブディレクトリ構成は持たない）、実際に
書き出されるのはdb trackの`./result/<obj>/`とapp trackのdiff/patchのみ
である。

## db track: `./result/<オブジェクト名>/`

対話的1件変換・後半の一括変換のいずれも同じ形式で出力する
（`write_db_result` MCPツール）。

```
./result/
└── <オブジェクト名>/          # スキーマ接頭辞を除いたオブジェクト名
    ├── oracle.sql             # 元のOracle DDL/コード（元のDDLファイル、
    │                          #   DBMS_METADATA.GET_DDL、またはユーザーが
    │                          #   対話で提供したもの。workflow-db-convert参照）
    ├── postgres.sql           # 変換後のPostgreSQL DDL/PL-pgSQL
    ├── test_result.txt        # 簡易実行テスト結果（run_ora_sql/run_postgres_sql）
    └── OK.txt または NG.txt   # 変換結果のサマリー（SCAW1.0形式を継承、下記参照）
```

### OK.txt / NG.txt（SCAW1.0形式を継承）

`write_db_result`に`status`（tool-db-inventory-schema skillのreview-status語彙、
例: `pass`, `fail`）と`summary`（本文テキスト）を渡すと、`status`に応じて
`OK.txt`または`NG.txt`のどちらか一方が書き出される（両方同時には存在しない。
再変換で結果が変わった場合、古い方のファイルは自動的に削除される）。

- `pass` / `no_change_needed` / `sct_already_handled` → `OK.txt`
- `partial_by_llm` / `validator_limitation` / `manual_review_range` /
  `manual_review_bind` / `fail` → `NG.txt`

`summary`の本文は、SCAW1.0のサマリー（`OK.txt`/`NG.txt`）の構成を踏襲し、エージェントが**必ず以下の見出し構成のまま**（省略・簡略化・
独自の見出しへの差し替えをしない）、各項目を埋めて渡す:

```
## 基本情報
- ステータス: <SUCCESS/FAILED、またはreview-status語彙の値>
- 変換対象: <オブジェクト名、タイプ（PROCEDURE/FUNCTION/TRIGGER等）>
- 実施日時: <YYYY-MM-DD HH:MM:SS>

## 変換の主な変更点
- データ型変更: 例: VARCHAR2(100) → VARCHAR(100)
- 構文変更: 例: NVL() → COALESCE()
- 削除した機能: 例: トランザクション制御（COMMIT/ROLLBACK）、理由: PostgreSQL関数内では使用不可

## テスト結果サマリー
- 実行したテストケース数: X件
- 成功/失敗の内訳: 成功 X件 / 失敗 Y件

## 注意事項
- 運用時に注意すべき点（例: トランザクション制御は呼び出し元で実装する必要があります）

## （NG.txtの場合のみ）失敗情報
- 失敗理由: 具体的なエラー内容
- 試行回数: X回
- 推奨される対応方法: 手動での対応が必要な箇所、追加で確認すべき依存関係
```

`status`/`summary`を省略した場合、`OK.txt`/`NG.txt`は書き出されない（後方互換）。

「後半の一括変換」で「残りのオブジェクト」を判定する際は、`./result/`配下に
既にディレクトリが存在するオブジェクト名を`list_converted_objects`ツールで
列挙し、対象オブジェクトリスト（`parse_sct_csv`で抽出したもの）との差分を取る。

## app track: diff / patch 出力

`write_app_convert_outputs` MCPツールが、指定した`mode`（`diff` / `patch` /
`inplace`）に応じて以下を出力する。

```
<out_dir>/
├── diffs/<相対パス>.diff      # mode=diff の場合、変更されたファイルごとに1つ
└── app-conversion.patch       # mode=patch の場合、1つの統合パッチファイル
                                # (mode=inplace の場合はソースファイルを直接書き換え、
                                #  出力ファイルは生成されない)
```

CSVインベントリやnarrative reportのようなファイルは、SCAW2.0では
出力しない（SCAW2.0の対象は変換のみで、アセスメントやレポートは扱わない）。

## `workshop-custom-rules/SKILL.md`

対話的変換のたびに、エージェントが発見した変換パターンを
`write_skill_draft`ツールで追記する（db track、app trackともに変換フローの
最後のステップ）。

```
agent/skills/workshop-custom-rules/SKILL.md
```

初期状態は見出しのみのテンプレート。ワークショップの進行に伴い内容が育つ。
このファイルは、プロジェクトルート直下の隠しファイルではなく、
`agent/skills/`配下の通常のSkillファイルとして管理され、参加者が自由に編集できる。

SCAW2.0の出力は上記の3種類（db resultディレクトリ、app diff/patch、
workshop-custom-rules）のみである。

## Related skills

- [workflow-db-convert](../workflow-db-convert/SKILL.md) — db track変換ワークフロー、`./result/<obj>/`を出力する手順
- [workflow-app-convert](../workflow-app-convert/SKILL.md) — app track変換ワークフロー、diff/patchを出力する手順
