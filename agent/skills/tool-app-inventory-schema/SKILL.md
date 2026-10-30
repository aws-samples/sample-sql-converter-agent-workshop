---
name: tool-app-inventory-schema
description: Explain the review-status vocabulary used when converting app-track embedded SQL in SCAW2.0. Use when the user asks "この変換結果はどういう意味?", "manual_review_bind って何?", or needs to interpret the outcome of an application SQL conversion. SCAW2.0 has no app-inventory-converted.csv (assess/report Out of Scope), so only the review-status vocabulary + host-language grouping notes are kept.
---

# App Track 変換結果の語彙

SCAW2.0は`app-inventory-converted.csv`のような21列のCSVインベントリを
出力しない（SCAW2.0の対象は変換のみで、アセスメントやレポートは扱わない）。変換結果を評価
する際の語彙（review status）と、変換対象の分類（Classification）は
以下の通り。エージェントは変換完了時、チャットの応答でこの語彙を使って
結果を説明する。

## Classification 語彙（変換難易度）

| 値 | 意味 | 例 |
|---|---|---|
| `A` | 決定的ルール変換で自動対応可能 | `NVL`→`COALESCE`、`SYSDATE`→`aws_oracle_ext.sysdate()` |
| `B` | 機械的だがイディオムの違いがあり、レビュー推奨 | `ROWNUM`ページネーション、`(+)`外部結合、単純な`CONNECT BY` |
| `C` | アプリケーションの意味を踏まえた設計判断が必要（手動変換） | 複雑な`CONNECT BY`+`SYS_CONNECT_BY_PATH`、パッケージレベルの状態 |
| `None` | 標準SQLで、Oracle固有機能なし | 変換不要 |

## Review Status 語彙

| Status | 意味 | 対応 |
|---|---|---|
| `pass` | LLM変換が成功し、`validate_pg_sql`/`validate_bind_integrity`が両方通った | 不要 |
| `no_change_needed` | Oracle固有機能が見つからず、変換不要 | 不要 |
| `orm_delegated` | ORM（Hibernate/MyBatis動的等）がdialect変換を担うため、変換を見送る | 不要（ORM側が対応） |
| `validator_limitation` | 変換後SQLは妥当だがpglastが検証できない（動的SQL文字列等） | 目視確認 |
| `manual_review_range` | 行保存の範囲内で書き換えられない構造的変更が必要 | 人による再設計 |
| `manual_review_bind` | バインド変数の個数・順序・名前が変わり、ホスト側コードの修正も必要 | ホスト側呼び出しも含めた人による対応 |
| `fail` | 検証ループを尽くしても妥当な変換ができなかった | 人による手動変換 |

## バインド整合性（CRITICAL、`validate_bind_integrity`が担当）

ホスト言語のプレースホルダ（JDBC `?`、Oracle `:name`、MyBatis `#{name}` /
`${name}`、PostgreSQL `$1..$n`、Python `%s` / `%(name)s`等）は、変換前後で
**総数が変わらないこと**が必須。総数が変わる場合はホスト側の
`stmt.setXxx(...)`呼び出しも変える必要があり、これは行保存変換の対象外
（`manual_review_bind`扱い、retryなし）。

**よくある落とし穴（ROWNUMページネーション）**: Oracleの
`WHERE ROWNUM <= :endRow ... WHERE rn >= :startRow`は2個のプレースホルダ。
素朴な`LIMIT (:endRow - :startRow + 1) OFFSET (:startRow - 1)`という変換は
`:startRow`を2回使うため総数が3個になり、バインド検証に失敗する。必ず
`WITH ranked AS (SELECT ROW_NUMBER() OVER (...) AS rn, ...) SELECT * FROM
ranked WHERE rn BETWEEN :startRow AND :endRow`のように、各プレースホルダが
1回だけ現れる形に変換する。

## ホスト言語別の変換範囲（参考）

| 拡張子 | 言語 |
|---|---|
| `.java` | Java |
| `.xml` | XML (MyBatis / iBATIS) |
| `.py` | Python |
| `.ts` / `.tsx` | TypeScript |
| `.js` / `.jsx` | JavaScript |
| `.php` | PHP |
| `.rb` | Ruby |
| `.cs` | C# |
| `.c` / `.h` / `.cpp` | C / C++ |
| `.vb` | VB |
| `.sql` | SQL |

## Related skills

- [workflow-app-convert](../workflow-app-convert/SKILL.md) — この語彙を使う変換ワークフロー本体
- [tool-output-layout](../tool-output-layout/SKILL.md) — diff/patch出力形式
