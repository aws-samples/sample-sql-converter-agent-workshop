---
name: tool-output-layout
description: 変換結果のファイルの配置と形式（db trackの`./result/<オブジェクト名>/`とOK.txt / NG.txtの雛形、app trackのdiff/patch、`workshop-custom-rules/SKILL.md`）。結果を書き出すとき、「どのファイルを見ればいい？」「出力ファイルの意味を教えて」と聞かれたときに使う。
---

# 出力ファイルの配置と形式

出力は、次の3種類だけである。ファイルは必ず対応するMCPツールで書き出す（`fs_write`で自分で作らない）。

## db track: `./result/<オブジェクト名>/`（`write_db_result`）

```
./result/<オブジェクト名>/     # スキーマ名を除き、大文字にしたオブジェクト名（例: PROC_A）
├── prerequisites.txt          # 前提条件の確認（対象と依存オブジェクトの有無、定義をどこから取得したか）
├── oracle.sql                 # 元のOracleの定義
├── oracle_test.sql            # Oracleで実行したテストのSQL
├── oracle_test.txt            # Oracleでのテストの結果
├── postgres.sql               # 変換後のPostgreSQL
├── postgres_test.sql          # PostgreSQLで実行したテストのSQL（Oracleと同じケース）
├── postgres_test.txt          # PostgreSQLでのテストの結果
├── comparison_result.txt      # ケースごとの比較（観点、一致したか、差異の原因と影響）
└── OK.txt または NG.txt       # 変換結果のサマリー
```

テストのファイルには、実際に実行したSQLと、`run_ora_sql` / `run_postgres_sql`が返した結果を書く（要約しない）。
各ケースに番号と観点（`tool-test-viewpoints`）を付け、Oracle側とPostgreSQL側で同じ番号を使う。
テストを実行しなかった場合は、空にして渡す（「実行していない」旨が書き出される。理由はsummaryに書く）。

`status`（`tool-review-status`の判定区分）でOK.txtかNG.txtが決まる。両方が同時にあることはない
（変換し直して結果が変わった場合、古い方のファイルは自動で削除される）。
変換し直すときに、`./result/<オブジェクト名>/`を削除する必要はない（もう一度書き出せば上書きされる）。
NG.txtの対応方法に、ディレクトリの削除を書かない。

### OK.txt / NG.txt の雛形

`summary`は、次の雛形の見出しと項目名のまま書く（`<>`の部分を埋める）。NG.txtのときだけ最後の
「失敗情報」も書く。見出しや項目名が足りないと、`write_db_result`は書き出しを断る。
「実施日時」は`write_db_result`が実際の日時に書き換える。

```
## 基本情報
- ステータス: <判定区分>
- 変換対象: <オブジェクト名、種類（PROCEDURE/FUNCTION/TRIGGERなど）>
- 実施日時: <YYYY-MM-DD HH:MM:SS>

## 変換の主な変更点
- データ型変更: <例: VARCHAR2(100) → VARCHAR(100)。なければ「なし」>
- 構文変更: <例: NVL() → COALESCE()。なければ「なし」>
- 削除した機能: <例: COMMIT/ROLLBACK（EXCEPTION句を持つブロックの中では使えないため）。なければ「なし」>

## テスト結果サマリー
- 実行したテストケース数: <X件>
- 成功/失敗の内訳: <成功 X件 / 失敗 Y件>
- 観点ごとの内訳: <正常系 X件 / 境界値 X件 / 異常系 X件 / エッジケース X件。対象外の観点は「異常系: 対象外（理由）」のように書く（`tool-test-viewpoints`）>

## 注意事項
- <運用時に注意すべき点、対応したAction Itemの番号、推測で補った箇所、要確認の事項>

## （NG.txtの場合のみ）失敗情報
- 失敗理由: <具体的なエラーの内容>
- 試行回数: <X回>
- 推奨される対応方法: <手で対応が必要な箇所、追加で確認すべき依存関係>
```

この雛形を変えると、`write_db_result`が検査する見出しと項目名も自動で変わる。

## app track: diff / patch（`write_app_convert_outputs`）

出力先（`out_dir`）は`./result/app-<アプリケーション名>/`にする。アプリケーション名は、指定されたディレクトリの名前とする。
ディレクトリの名前が`application`や`src`のような一般的な名前の場合は、その上のディレクトリの名前を使う
（例: `./input-sample/application/employee-mgmt/application` → `./result/app-employee-mgmt/`）。

既定（`mode`が`file`）では、指定されたディレクトリ（アプリケーション）単位で、次のように出力する。

```
./result/app-<アプリケーション名>/
├── converted/<ファイルの相対パス>  # 変換後のファイル全体（元のファイル名のまま。例: converted/EmployeeDao.java）
├── diffs/<ファイルの相対パス>.diff # 元のファイルとの差分（例: diffs/EmployeeDao.java.diff）
├── oracle_test.sql                # Oracleで実行したテストのSQL（ファイルごとに「===== <ファイル> =====」の見出し）
├── oracle_test.txt                # Oracleでのテストの結果
├── postgres_test.sql              # PostgreSQLで実行したテストのSQL（Oracleと同じケース）
├── postgres_test.txt              # PostgreSQLでのテストの結果
├── comparison_result.txt          # ケースごとの比較
└── OK.txt または NG.txt           # ディレクトリ全体のサマリー（すべてのファイルがOKならOK.txt、1つでもNGならNG.txt）
```

- `per_file_results`に、置き換えるファイルごとの`status`、`summary`とテストの5つを渡す（ないと書き出しを断る）。
  SQLはあるが変更が不要だったファイルは、`per_file_results`だけに`no_change_needed`で渡す。
- テストのファイルとOK.txt / NG.txtは、ツールがファイルごとの結果をまとめて作る（見出しはツールが付ける）。
  OK.txt / NG.txtには、全体の判定、ファイルごとの結果の一覧、ファイルごとのsummaryが入る。
  何回かに分けて書き出しても、並列のサブエージェントが同じディレクトリに書き出しても、それまでのすべてのファイルの結果でまとめ直される。
- ファイルごとの`summary`は上の雛形のとおりに書く。`status`は、そのファイルのSQLのうち一番悪い判定区分にする。
  「変換対象」には、ファイル名とSQL（メソッド名やマッパーのid）を書き、「注意事項」に要確認の事項を書く。
- テストのSQLと結果には、SQL（メソッド名やid）ごとに見出しを付け、各ケースに番号と観点を付ける。動的SQLは、分岐ごとに
  組み上げたSQLを書く。

| mode | 出力 |
|---|---|
| `file`（既定） | 上の構成（ディレクトリ単位のテストとサマリー、変換後のファイル全体と差分） |
| `diff` | `<出力先>/diffs/<相対パス>.diff`（ファイルごと、差分だけ） |
| `patch` | `<出力先>/app-conversion.patch`（1つにまとめる） |
| `inplace` | 元のファイルを直接書き換える（出力ファイルなし） |

`project_root`には、指定されたアプリケーションのディレクトリの絶対パスを渡す（リポジトリのルートではない）。
出力のパスは`project_root`からの相対パスになる。

## 変換パターン: `agent/skills/workshop-custom-rules/SKILL.md`（`write_skill_draft`）

前半の対話的な変換で見つけた変換パターンを追記する。追記案を文章で示し、参加者の了承を得てから`write_skill_draft`を呼ぶ
（呼んだ時点でファイルに追記される）。参加者が自由に編集してよい。
