---
name: domain-proc-to-ecpg
description: Reference card for Oracle Pro*C (.pc embedded SQL) → PostgreSQL ECPG migration (EXPERIMENTAL track — validated on synthetic fixtures, not yet on a real customer Pro*C codebase; review all outputs). Use when assessing or converting EXEC SQL statements, host variables, indicator variables, SQLCA error handling (sqlca.sqlcode 1403 vs 100), WHENEVER directives, host arrays / FOR :n bulk operations, SQLDA Method-4 dynamic SQL, embedded PL/SQL blocks (EXEC SQL EXECUTE ... END-EXEC), CONNECT statements, or EXEC ORACLE precompiler options. Also covers the ecpg -C ORACLE compatibility mode. The host C code itself stays C — this skill covers the embedded-SQL dialect change only, NOT host-language rewrites (Pro*C→Java etc. is out of scope).
---

# Pro*C → ECPG 変換リファレンス

> **実験的機能**: Pro*Cトラック（検出＋変換）は合成テストフィクスチャと
> 1件のend-to-end統合テストケースで検証済みだが、実際の顧客Pro*Cコード
> ベースではまだ検証していない。変換結果はレビュー前提の下書きとして
> 扱い、必ず実際の`ecpg`/`cc`ツールチェーンでプリコンパイル・ビルドし、
> 実行時の挙動（SQLCAの意味論、接続先、カーソルのライフタイム）を
> 確認すること。

Oracle Pro*CとPostgreSQL ECPGは、どちらもC言語向けの埋め込みSQL
プリコンパイラである。ホストC言語コードの約95%はそのままで、移行作業の
大半は`EXEC SQL`文、SQLCA/SQLDAランタイムAPI、プリコンパイラオプションに
集中する。`detect_proc_sql` MCPツールが各構文を検出し、以下の表を使って
事前分類を行う（構文クラスとSQL方言クラスのうち、より重い方が優先される
— `EXEC SQL`内のSQL自体は`domain-conversion-rules`での変換対象になる）。

## ビルドチェーンの対応

| | Oracle Pro*C | PostgreSQL ECPG |
|---|---|---|
| プリコンパイラ | `proc` | `ecpg`（PostgreSQLに同梱） |
| 拡張子 | `.pc` | `.pgc`（慣例） |
| 出力 | `.c` | `.c` |
| ランタイムライブラリ | `libclntsh` / SQLLIB | `libecpg` |
| 互換フラグ | — | `ecpg -C ORACLE`（PG 11+） |

**`ecpg -C ORACLE`は重要**: Oracle寄りの挙動を有効化する — `char`型の
ホスト変数がPro*Cの`MODE=ORACLE`同様ゼロ終端・ブランクパディングされる、
空文字列の扱いがOracle方式になる、sqlda出力モードがOracle形式（ネイティブ）
になる。`-C ORACLE`前提で変換するのが基本方針であり、これにより文字列
パディングに関する書き換えの多くが不要になる。

## 構文分類表（`detect_proc_sql`の事前分類）

`agent/tools/proc_constructs.py`（`detect_proc_sql`が参照する分類テーブル）
に対応している。

### A — 機械的な書き換え

| 構文 | Pro*C | ECPG | 備考 |
|---|---|---|---|
| 宣言セクション | `EXEC SQL BEGIN/END DECLARE SECTION;` | 同じ | ECPGは素の変数宣言も受け付ける |
| SQLCAのINCLUDE | `EXEC SQL INCLUDE SQLCA;` | `EXEC SQL INCLUDE sqlca;` | 構造体名は同じ |
| WHENEVER | `WHENEVER SQLERROR/SQLWARNING/NOT FOUND` + `CONTINUE/GOTO/STOP/DO fn()` | 同じアクション、加えて`DO BREAK`/`DO CONTINUE`/`CALL` | スコープはどちらも字句的 |
| カーソル操作 | `OPEN/FETCH/CLOSE` | 同じ | `FETCH`の方向キーワードも両対応 |
| VARCHAR擬似型 | `VARCHAR v[40];` → struct {len, arr} | ECPGも同じ展開 | フィールド名も一致（`.len`、`.arr`） |
| 指示変数（indicator variable） | `:v:ind` / `:v INDICATOR :ind` | 同じ構文 | NULL判定の-1は両方一致 |
| COMMIT / ROLLBACK | `EXEC SQL COMMIT;` | 同じ | `RELEASE`はB参照 |

### B — サポートされるが意味・APIが異なる（レビュー推奨）

| 構文 | 差異 | 書き換え方法 |
|---|---|---|
| `sqlca.sqlcode == 1403`（データなし） | Oracle: +1403（MODE=ANSIでは+100）。ECPG: **ECPG_NOT_FOUND = 100** | マジックナンバーを置き換える。`WHENEVER NOT FOUND`または`sqlca.sqlcode == ECPG_NOT_FOUND`を推奨 |
| `sqlca.sqlerrd[2]`（処理行数） | ECPGも同じスロット（`sqlerrd[2]`）を使うが他スロットの意味は異なる（パース位置等のOracle固有スロットは0） | 利用箇所ごとに確認 |
| `sqlca.sqlerrm.sqlerrmc` | ECPGにも存在、メッセージ内容が異なる。Oracleの`sqlglm()`はECPGにない | 構造体アクセスは残し、`sqlglm`呼び出しは削除 |
| `sqlca.sqlwarn`フラグ | ECPGでは立つフラグが少ない | 利用箇所ごとに確認 |
| CONNECT | `CONNECT :u IDENTIFIED BY :p [AT db] [USING :dbstring]` | `CONNECT TO target [AS name] [USER user]` | DSN/接続先の構文が異なる。TNS名→host/port/dbへ |
| AT句（名前付き接続） | `EXEC SQL AT db ...` | `EXEC SQL AT conn ...` | サポートされるが接続の命名方式が異なる |
| `COMMIT WORK RELEASE` | 接続を解放する | `RELEASE`相当はなく、COMMIT後に`EXEC SQL DISCONNECT`を使う | 2文に分割 |
| ホスト配列 / `FOR :n` | Pro*Cはネイティブに配列バインド・バルクフェッチ対応 | ECPGも配列ホスト変数とDML文のFORをサポートするが制約あり（部分配列フェッチの制御不可） | 文ごとに確認 |
| ANSI記述子 | `ALLOCATE/GET/SET DESCRIPTOR` | サポート（SQL標準方式） | 項目名を確認 |
| 動的SQL Method 1〜3 | `EXECUTE IMMEDIATE`、`PREPARE`/`EXECUTE`、`PREPARE`+カーソル | 同じ文が存在 | SQL本文（C文字列であることが多い）自体はOracle→PG変換が別途必要 |
| `EXEC ORACLE OPTION` | プリコンパイラオプション（HOLD_CURSOR, RELEASE_CURSOR, MODE, MAXOPENCURSORS） | 相当するものはなく、挙動差はECPGのデフォルト/`-C ORACLE`で吸収される | 削除し、カーソルのライフタイム前提を見直す |
| `EXEC SQL TYPE/VAR`による型対応 | 独自の型マッピング | `EXEC SQL TYPE`は存在するが型セットが異なる | 変数ごとに再マッピング |

### C — 手動での再設計が必要

| 構文 | 理由 | 対応方針 |
|---|---|---|
| Oracle SQLDA / Method-4（`INCLUDE SQLDA`、`sqlald()`、`sqlnul()`、`USING/INTO DESCRIPTOR`） | ECPGの`sqlda`は構造体・割り当てモデルが異なる | ECPGネイティブ/互換sqlda（`-C ORACLE`でOracle形式のsqldaになる）かANSI記述子に対して書き換える。呼び出し箇所ごとの書き換えが必要 |
| 埋め込みPL/SQLブロック（`EXEC SQL EXECUTE BEGIN ... END; END-EXEC`） | PostgreSQLにPL/SQLはない | `EXECUTE IMMEDIATE`経由の`DO $$...$$`として書き換える、またはサーバー側関数に昇格させる。PL/SQL本体の変換は`domain-conversion-rules`（PL/SQL→PL/pgSQL部分）を使う |
| OCIインターオペ（`sqllda`、`sqlld2`、`sqlglm`、`sqlgls`） | SQLLIB専用API | libpqまたはECPGネイティブのエラーAPIで再設計 |
| `EXEC SQL ENABLE THREADS` / `CONTEXT ALLOCATE/USE/FREE` | Pro*Cランタイムコンテキストのスレッドモデル | ECPGのスレッドは1スレッド1接続が基本（`ecpg -t`やautocommitの意味論が異なる）。接続管理を再設計 |
| `ARRAYLEN` | Pro*C専用ディレクティブ | 削除し、明示的なループや配列サイズで表現し直す |

## 変換の進め方（SCAW2.0版）

Pro*Cは`workflow-app-convert`skillの対話的変換フロー（app worker:
`scaw-migration-app`）の中で、他のホスト言語（Java/MyBatis XML等）と
同様に扱われる。専用のバッチツールやLLM内蔵の変換ツールは存在せず、
db/app trackの他オブジェクトと同じく**エージェント自身がLLM変換を担う**
（MCPツール層はLLM APIを呼ばない方針）。

1. `detect_proc_sql`で`.pc`ファイル内の構文を検出し、上記A/B/C分類表に
   基づいて事前分類された結果を得る（決定的処理、LLM不使用）。
2. 分類Cの構文（SQLDA Method-4、`FOR :n`ホスト配列、埋め込みPL/SQL、
   `EXEC ORACLE`オプション等）は人間レビューに回す（`manual_review_range`
   相当、LLMには回さない）。
3. 分類A/Bのうち、決定的ルールで対応できるもの（`COMMIT WORK RELEASE` →
   `COMMIT; DISCONNECT ALL;`、`sqlca.sqlcode == 1403` → `== 100`等）は
   エージェントがそのまま置き換える。
4. 残りはエージェントがLLM変換を行う。ホスト変数の整合性（`:name` /
   `:name:ind`が変換前後で全て保持されていること）は`validate_bind_integrity`
   で検証し、違反はリトライせず`manual_review_bind`として報告する。
5. 検証には`validate_ecpg`（`EXEC SQL`ラッパー構文のチェック）と
   `validate_pg_sql`（サーバー側SQLのチェック、`INTO`句は除いて検証）の
   両方を使う。

**確認済みのecpgの挙動**（ecpg 18.4、`-C ORACLE`）: `EXEC SQL`ラッパー＋
ホスト変数宣言＋指示変数の型は検証する。`COMMIT WORK RELEASE` /
`FOR :n` / `END-EXEC`ブロック / 未宣言変数は**拒否**する。Oracle形式の
CONNECT文は受け付け、かつ重要な点として**Oracle固有のSQL（NVL /
ROWNUM等）をそのまま通してしまう**ため、`validate_ecpg`だけでなく常に
`validate_pg_sql`も併用する必要がある。

**Pro*C行のSQL抽出規則**: サーバーに送るSQLのみを対象とする —
`EXEC SQL`プレフィックスを含めない、`INTO :host`句も含めない（ecpgが
サーバー送信前に取り除くため）。`:name`バインドは`converted_lines`には
残すが、`validate_bind_integrity`に渡す際は`$N`形式に正規化する。

## 検出時の留意点

- `detect_proc_sql`は、（`EXEC SQL`の外側の）ホストC言語コード内にある
  SQLCA関連の記述（例: `sqlca.sqlcode == 1403`のようなマジックナンバー
  比較）も検出対象として報告する。これらはSQLを含まないが実質的な
  移行作業として扱う。
- C文字列リテラル内に埋め込まれた動的SQL文字列も検出対象として報告
  される。`EXEC SQL`文の中になくても、他のOracle SQLと同様に変換が
  必要。

## 対象外

- ホスト言語自体の変更（Pro*C → Java/JDBC等）— 別プロジェクトとして扱う
- Pro*COBOL（`.pco`）— このskillおよび`detect_proc_sql`の対象外
- プロジェクト全体のプリコンパイル・リンク — 変換フェーズでは文単位の
  検証（`validate_ecpg`）までを行う。ファイル全体の`ecpg`+`cc`ビルドは
  手動（またはCI側）での対応が必要
