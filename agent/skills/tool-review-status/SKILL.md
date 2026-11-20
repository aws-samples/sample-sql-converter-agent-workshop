---
name: tool-review-status
description: 変換結果の判定区分（pass、manual_review_rangeなど）の一覧。変換結果を報告するとき、OK.txt / NG.txtのどちらになるかを決めるとき、「この変換結果はどういう意味？」「manual_review_bindって何？」と聞かれたときに使う。
---

# 変換結果の判定区分

変換が終わったら、次の判定区分で結果を表す。db trackでは`write_db_result`の`status`に渡し、
`test_result.txt`とチャットの応答でも使う。app trackではチャットの応答で使う。

| 判定区分 | 意味 | 必要な対応 | 対象 | db trackの出力 |
|---|---|---|---|---|
| `pass` | 変換し、検証（validate_pg_sql、validate_bind_integrity、実行テスト）がすべて通った | なし | db / app | OK.txt |
| `no_change_needed` | Oracle固有の機能がなく、変換は不要 | なし | db / app | OK.txt |
| `sct_already_handled` | SCTがすでに正しく変換しており、書き換えは不要 | なし | db | OK.txt |
| `orm_delegated` | ORM（Hibernate、MyBatisの動的SQLなど）がSQLの方言の違いを吸収するため、変換を見送った | なし | app | ― |
| `partial_by_llm` | 一部を変換したが、未解決の部分が残る | 残りを人が確認する | db | NG.txt |
| `validator_limitation` | 変換後のSQLは妥当だが、検証ツールでは確かめられない | 目で確認する | db / app | NG.txt |
| `manual_review_range` | 構造的な書き換え（パッケージの再設計、DBMS_SCHEDULER → pg_cronなど）が必要で、変換を見送った | 人が設計し直す | db / app | NG.txt |
| `manual_review_bind` | バインド変数の個数・順序が変わり、呼び出し元のコードの修正も必要 | 呼び出し元も含めて人が対応する | db / app | NG.txt |
| `fail` | 検証と再変換を繰り返しても、妥当な変換ができなかった | 人が手で変換する | db / app | NG.txt |

区分を厳密に使い分けることよりも、「うまく変換できた」「ここは確認が必要」が参加者に伝わることを優先する。
