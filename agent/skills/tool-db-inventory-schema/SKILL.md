---
name: tool-db-inventory-schema
description: Explain the review-status vocabulary used when converting a db-track object in SCAW2.0. Use when the user asks "この変換結果はどういう意味?", "manual_review_range って何?", or needs to interpret the outcome of a db object conversion. SCAW2.0 has no db-inventory-converted.csv (assess/report Out of Scope), so only the review-status vocabulary is kept here; it is surfaced in test_result.txt / chat responses instead of a CSV column.
---

# DB Track 変換結果の語彙

SCAW2.0は`db-inventory-converted.csv`のような15列のCSVインベントリを
出力しない（SCAW2.0の対象は変換のみで、アセスメントやレポートは扱わない）。変換結果を評価
する際の語彙（review status）は以下の通り。エージェントは変換完了時、
`test_result.txt`やチャットの応答の中でこの語彙を使って結果を説明する。

## Review Status 語彙

| Status | 意味 | 対応 |
|---|---|---|
| `pass` | LLM変換が成功し、全ての検証（validate_pg_sql、簡易実行テスト）が通った | 不要 |
| `no_change_needed` | 変換対象のaction itemがない、または既にPostgreSQL互換 | 不要 |
| `sct_already_handled` | SCTが既に正しく変換済みで、LLM呼び出し不要と判断された | 不要 |
| `partial_by_llm` | LLMが一部変換したが、コメントで示された未解決部分が残る | 残りの部分を人が確認 |
| `validator_limitation` | 変換後のSQLは妥当だが、validate_pg_sqlが構文を検証できない（稀） | 目視確認 |
| `manual_review_range` | 構造的な書き換えが必要（パッケージ再設計、DBMS_SCHEDULER→pg_cron等）で、LLMが自動変換を見送った | 人による再設計 |
| `manual_review_bind` | バインド変数の個数・順序が変わり、呼び出し元コードの修正も必要 | 呼び出し元も含めた人による対応 |
| `fail` | 検証ループ（retry）を尽くしても妥当なPostgreSQLを生成できなかった | 人による手動変換 |

8値を厳密に区別するのではなく、SCAW2.0では対話の中で
エージェントがこの語彙を使って参加者に「うまく変換できた」「ここは確認
が必要」と伝える程度の運用でよい（ガチガチに作り込まない方針）。

## 大規模書き換えが必要なケースの判断材料（`manual_review_range`相当）

以下は構造的な書き換えが必要か判断する際の基準
（`workflow-db-convert/SKILL.md`にも統合済み）。

**構造的書き換えが必要（LLMに丸投げせず人に相談すべき）**:
DBMS_SCHEDULER.CREATE_JOB/DROP_JOB、DBMS_AQ.ENQUEUE/DEQUEUE、
DB LINK経由の読み書き、DBMS_SQL.DESCRIBE_COLUMNS等の動的カラムメタデータ、
UTL_HTTP/UTL_SMTP/UTL_FILE/UTL_TCP、MATERIALIZED VIEWへの直接DML、
パッケージを名前空間として使うケース、CLUSTER、直接対応のないXMLTYPE関数。

**構造的書き換え不要（本体を書き換えればよい）**:
NVL/DECODE/SYSDATE/ROWNUM/CONNECT BY/LISTAGG、DBMS_OUTPUT.PUT_LINE、
DBMS_RANDOM、DBMS_LOB.GETLENGTH、VARCHAR2/NUMBER、Oracleヒント、
CURSOR、FROM DUAL、:NEW/:OLD、EXCEPTION WHEN OTHERS。

## Related skills

- [workflow-db-convert](../workflow-db-convert/SKILL.md) — この語彙を使う変換ワークフロー本体
- [tool-output-layout](../tool-output-layout/SKILL.md) — `./result/<obj>/`の出力形式
