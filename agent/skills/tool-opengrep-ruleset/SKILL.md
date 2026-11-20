---
name: tool-opengrep-ruleset
description: opengrepの静的解析で、アプリケーションのソース（Java、Python、PHPなど）に埋め込まれたSQLの位置を見つける方法（`detect_sql_by_opengrep`）。文字列の連結やStringBuilderで組み立てる動的SQLを探すとき、opengrepの結果の読み方や、opengrepで見つからなかったSQLの扱いを確かめるときに使う。
---

# opengrepによるSQLの位置の特定

`detect_sql_by_opengrep`は、ファイルごとに2つのルールで解析する。ルールは`agent/tools/rules/`のYAMLにある。

| ルール | 見つけるもの | 方式 |
|---|---|---|
| `opengrep_pattern_rules.yaml` | SQLの文字列リテラル、`@Select` / `@Query` / `@NamedQuery`などのアノテーション、`cursor.execute("...")` | pattern |
| `opengrep_taint_rules.yaml` | 組み立てるSQL（`+=`、`StringBuilder.append`、分岐の中での連結、`String.format`、f文字列など） | taint（ファイル内のデータフロー） |

taintは、SQLの文字列を入れた変数（ソース）から、それを実行する呼び出し（シンク: `executeQuery`、`execute`、
`prepareStatement`、`createQuery`、JdbcTemplateの`query`など。Javaでは、同じクラスのメソッドに渡す呼び出し
（`query(sql, params)`など）もシンクとして扱う）までをたどり、その範囲を1つのSQLとして返す（`dynamic: true`）。
patternの結果がtaintの範囲の中にある場合は、同じSQLを二重に数えないよう除く。

## 使い方

- `scan_for_sql_files`が`source`に分類したファイルを、まとめて`detect_sql_by_opengrep`に渡す（1回の起動で複数ファイルを解析する）。
- 返った`start_line`〜`end_line`を読んで、SQLの範囲を確かめる。行の範囲はヒューリスティックで補正しているため、ずれることがある。
  置き換える範囲は、読んで決める。
- `dynamic: true`の範囲は、条件によってWHERE句やORDER BY句が変わる。実行して確かめるときは、分岐ごとに組み上がるSQLを作って両方のDBで実行する。
- `ok: false`（opengrepが入っていない、時間切れなど）や、ファイルの`errors`がある場合は、そのファイルを読んでSQLを探す。

## opengrepでは足りない場合

| 対象 | 使うもの |
|---|---|
| MyBatis / Hibernate / iBATISのXML | `detect_xml_sql` |
| `.properties`（Seasar2 / S2Daoなど） | `detect_properties_sql` |
| `.sql`ファイル | `detect_sql_file` |
| Pro*C（`.pc`） | `detect_proc_sql` |
| ヒアドキュメント（PHPの`<<<SQL`、Rubyの`<<-SQL`）、独自のラッパー経由の実行 | ファイルを読んで探す |

## 言語ごとの注意

| 言語 | 注意 |
|---|---|
| Java | アノテーション（`@Query`、`@NamedQuery`）は、`@NamedQueries`の中の1つずつが別のSQLになる |
| Python | f文字列、`"".format()`、`%s`の埋め込み |
| PHP | `PDO->prepare(...)`、`oci_parse(...)`がシンク |
| JS / TS | テンプレートリテラル（バッククォート） |
| C# | 文字列補間`$"..."`、逐語的文字列`@"..."` |
| Ruby | `ActiveRecord::Base.connection.execute`、`Sequel.lit` |
| C / C++ | `OCIStmtPrepare(...)`、複数行に分けた隣接する文字列リテラル |

## 決まりごと

- opengrepを`execute_bash`などで直接呼ばない。`detect_sql_by_opengrep`を使う（ルールと行の補正が適用される）。
- 解析は、ファイルの文字列とデータフローのパターンによるもので、意味の解析ではない。見つからなかったことは、SQLがないことの証明にならない。
