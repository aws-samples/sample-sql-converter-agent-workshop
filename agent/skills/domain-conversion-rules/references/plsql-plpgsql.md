# PL/SQL → PL/pgSQL の変換

PL/SQLからPostgreSQLのPL/pgSQLへの変換ルール。親: [../SKILL.md](../SKILL.md)。

主な対象はDBオブジェクト（DDL、ストアドプロシージャ、ファンクション、パッケージ）。多くのルールは無名PL/SQLブロックにも当てはまる。

## 基本方針

- PL/SQLの構文をPL/pgSQLの構文に変換する
- 元のコードのコメントを残す
- トランザクション制御（COMMIT、ROLLBACK）は、下記「トランザクション制御」に従う。
- **関数の中に関数を定義すること（ネスト）はできない**。内側の関数は独立した関数として定義し、元の処理から呼び出す。

## FUNCTIONとPROCEDUREの使い分け

| 必要なこと | PostgreSQLで使うもの |
|---|---|
| 戻り値を返す | FUNCTION |
| 処理だけで戻り値なし | `void`を返すFUNCTION（単純な場合）またはPROCEDURE |
| 中でCOMMIT/ROLLBACKする | PROCEDURE（11以降）。`CALL`で呼ぶ（使えない場合がある。下記「トランザクション制御」） |
| 1行ずつ返す（パイプライン） | SETOF / TABLEを返すFUNCTION |
| OUTパラメータ | どちらも使える。14以降はPROCEDUREの方が自然に書ける |

## トランザクション制御（COMMIT / ROLLBACK）

### 使える場所

| 書かれている場所 | PostgreSQLで使えるか |
|---|---|
| FUNCTION、トリガー関数の中 | 使えない |
| PROCEDURE（11以降）の中 | 使える。ただし次の2つの場合は使えない |
| EXCEPTION句を持つブロックの中（PROCEDUREでも） | 使えない（`cannot commit while a subtransaction is active`）。本体の一番外側にEXCEPTION句があれば、本体のどこでも使えない。SCTのAction Item 5035はこの場合 |
| 呼び出し側の明示的なトランザクション（`BEGIN` ... `COMMIT`）の中や、FUNCTIONの中から`CALL`されたPROCEDURE | 使えない（`invalid transaction termination`）。SpringなどのフレームワークがトランザクションをPROCEDUREの外で始めている場合（`@Transactional`など）もこれにあたる |

### 対応の方針

1. **残せるなら残す**: OracleのPROCEDUREをPostgreSQLのPROCEDUREにし、COMMIT / ROLLBACKがEXCEPTION句の外にあり、
   呼び出し元がトップレベルから`CALL`する（自分でトランザクションを始めない）なら、COMMIT / ROLLBACKはそのまま残す。
   途中でCOMMITするバッチ処理など、Oracleでの動き（ロックの解放、途中までの確定）を保てる。
2. **残せないなら呼び出し元に移す**: 上の条件に合わない場合（EXCEPTION句の中にある、FUNCTIONにする、呼び出し元が
   トランザクションを持っている）は、PROCEDUREからは削除し、「トランザクション制御は呼び出し元で実装する必要があります」という
   コメントを付ける。SCTのAction Item 5035の推奨もこの方法。
3. **OracleのFUNCTIONにCOMMIT / ROLLBACKがある場合**: FUNCTIONのまま変換し、COMMIT / ROLLBACKは削除して呼び出し元に移す。
   PROCEDUREに変えると、呼び出し方（`SELECT`や代入から`CALL`へ）と戻り値の受け取り方が変わり、呼び出し元をすべて直す必要が
   あるため、自分の判断では変えない。PROCEDUREにした方がよいと考えた場合は、要確認として提案する。
4. **EXCEPTION句の中のCOMMITを残したい場合**: EXCEPTION句を持たないブロックでCOMMITするように構造を変えることはできるが、
   エラー処理とCOMMITの順序が変わるため、自分の判断では変えない。要確認として提案する。

どちらにしたか（残した / 呼び出し元に移した）と理由を、結果の「削除した機能」や「注意事項」に書く。
理由は上の表のどの場合にあたるかで書く（例: 「EXCEPTION句を持つブロックの中ではCOMMIT/ROLLBACKを使えないため」）。
「PostgreSQLのプロシージャではCOMMIT/ROLLBACKを使えない」とは書かない。

### 例外ハンドラの中のROLLBACK

PostgreSQLは、例外がブロックの外に出るとき、そのブロックで行った変更を自動で取り消す。

| Oracle | PostgreSQL |
|---|---|
| `EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;` | `EXCEPTION WHEN OTHERS THEN RAISE;`（ROLLBACKは不要なので削除する） |
| `EXCEPTION WHEN OTHERS THEN ROLLBACK; <処理を続ける>` | Oracleとは取り消される範囲が変わる。機械的に変換せず、要確認として報告する |

### トリガーの中のROLLBACK

トリガー関数はCOMMIT / ROLLBACKを使えない。処理を取り消したい場合は`RAISE EXCEPTION`にする
（例外で元の文ごと取り消される）。

### 自律型トランザクション（PRAGMA AUTONOMOUS_TRANSACTION）

PostgreSQLには自律型トランザクションがない。SCT / DMS SCが`aws_oracle_ext.autonomous_exec(...)`で置き換えている場合は、
そのまま使う。そうでない場合は、構造的な書き換え（`manual_review_range`）として扱う。代わりの方法は、dblinkで別の接続から
書き込む、アプリケーション側で記録する、設計を見直して呼び出し元のトランザクションに含める、のいずれか。

### 長いトランザクションに注意

Oracleで途中でCOMMITしていた処理を、1つのトランザクションにまとめると、PostgreSQLではロックが長く残る、不要な行が
VACUUMで回収されにくくなる、レプリカへの反映が遅れる、といった影響が出る。途中のCOMMITに理由がありそうなら、
方針1（残す）にするか、呼び出し元で区切ってCOMMITするよう要確認として伝える。

## 例外処理

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `EXCEPTION WHEN NO_DATA_FOUND THEN ...` | `EXCEPTION WHEN NO_DATA_FOUND THEN ...` | 同じ |
| `EXCEPTION WHEN OTHERS THEN ...` | `EXCEPTION WHEN OTHERS THEN ...` | 同じ |
| `EXCEPTION WHEN DUP_VAL_ON_INDEX THEN ...` | `EXCEPTION WHEN unique_violation THEN ...` | 名前が異なる |
| `RAISE_APPLICATION_ERROR(-20001, 'msg')` | `RAISE EXCEPTION 'msg' USING ERRCODE = '20001'` | |
| `SQLCODE`、`SQLERRM` | `SQLSTATE`、`SQLERRM` | SQLSTATEは5文字のコード |
| ユーザー定義の例外 | 独自の例外を宣言して発生させる | |

例:

```sql
-- Oracle
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Not found');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;

-- PostgreSQL
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE EXCEPTION 'Not found' USING ERRCODE = '20001';
  WHEN OTHERS THEN
    -- トランザクション制御は呼び出し元で実装する必要があります
    RAISE;
```

## カーソル属性

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `cursor%FOUND` | `FOUND` | FETCHの後 |
| `cursor%NOTFOUND` | `NOT FOUND` | FETCHの後 |
| `cursor%ROWCOUNT` | `GET DIAGNOSTICS n = ROW_COUNT` | |
| `cursor%ISOPEN` | 直接の対応なし。真偽値のフラグを使う | |

```sql
-- Oracle
OPEN cur;
LOOP
  FETCH cur INTO r;
  EXIT WHEN cur%NOTFOUND;
  -- 処理
END LOOP;
CLOSE cur;

-- PostgreSQL
OPEN cur;
LOOP
  FETCH cur INTO r;
  EXIT WHEN NOT FOUND;
  -- 処理
END LOOP;
CLOSE cur;
```

## 動的SQL

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `EXECUTE IMMEDIATE 'stmt'` | `EXECUTE 'stmt'` | |
| `EXECUTE IMMEDIATE stmt INTO var` | `EXECUTE stmt INTO var` | |
| `EXECUTE IMMEDIATE stmt USING a, b` | `EXECUTE stmt USING a, b` | |
| `DBMS_SQL.*`（明示的なカーソル） | `USING`付きの`EXECUTE`、またはプロシージャ | SCTの出力が`aws_oracle_ext.dbms_sql$*`を使っていればそのまま使う |

## FORALL / BULK COLLECT

PostgreSQLにはFORALL / BULK COLLECTがない。代わりの書き方:

| Oracle | PostgreSQL |
|---|---|
| `FORALL i IN ... INSERT` | 1つの`INSERT INTO t SELECT ...`、または`INSERT ... FROM unnest(array)` |
| `BULK COLLECT INTO array` | `SELECT array_agg(...)`、またはSETOFを返すクエリ |

```sql
-- Oracle
FORALL i IN 1..ids.COUNT
  INSERT INTO t VALUES (ids(i), names(i));

-- PostgreSQL
INSERT INTO t (id, name)
SELECT * FROM unnest(ids, names);
```

## TYPE / RECORDの変換

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `TYPE rec IS RECORD (...)` | `CREATE TYPE rec AS (...)`、またはローカルのレコード変数 | |
| `TYPE arr IS TABLE OF type`（ネストした表） | 配列型、または複合型のTABLE | |
| `TYPE arr IS TABLE OF type INDEX BY BINARY_INTEGER`（連想配列） | `hstore`拡張または`jsonb`でキーと値を持つ | |
| `TYPE arr IS VARRAY(N) OF type` | `type[]`（PostgreSQLの配列は上限なし） | |

## メソッドを持つオブジェクト型

Oracleのメソッド付きオブジェクト型（`CREATE TYPE ... AS OBJECT ... MEMBER FUNCTION ...`）には、PostgreSQLに直接の対応がない。選択肢:

- **複合型（composite TYPE）** と、その型を扱う別の関数
- 半構造化データなら **JSONB**
- **アプリケーション側のオブジェクト**（ロジックをDBの外に出す）

## 戻り値

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `RETURN value`（FUNCTION内） | `RETURN value` | 同じ |
| `RETURN QUERY SELECT ...` | `RETURN QUERY SELECT ...` | 同じ（SETOFを返す関数） |
| `PIPE ROW(rec)`（パイプライン関数） | SETOFを返す関数の中で`RETURN NEXT rec` | |
| `PIPELINED`キーワード | `RETURNS SETOF ...`または`RETURNS TABLE (...)` | |

## PL/SQL内のCONNECT BY

[structural-conversions.md](./structural-conversions.md#階層クエリconnect-by--with-recursive)を参照。PL/pgSQLのブロック内でも同じルールを使う。

## Oracleの組み込みパッケージ（UTL_*、DBMS_*）

Oracleの組み込みパッケージには、PostgreSQLに直接の対応がないものが多い。SCTの出力が拡張パックの関数（`aws_oracle_ext.*`）を使っていれば、それをそのまま使う。

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| `UTL_FILE`（ファイル入出力） | `COPY`コマンド、`pg_read_file()`、またはアプリケーション側でのファイル処理 | サーバー側の`COPY`はスーパーユーザーが必要 |
| `UTL_HTTP`（HTTP呼び出し） | `http`拡張、またはアプリケーション側 | |
| `UTL_SMTP`（メール） | アプリケーション側 | |
| `DBMS_SCHEDULER` | `pg_cron`拡張、または外部のスケジューラー（cron、Airflow） | |
| `DBMS_LOB`（LOBの操作） | `TEXT`/`BYTEA`の演算子を直接使う。非常に大きいデータは`pg_largeobject` | |
| `DBMS_OUTPUT.PUT_LINE` | `CALL aws_oracle_ext.dbms_output$put_line(...)` | 拡張パック。SCT / DMS SCの出力と同じ書き方 |
| `DBMS_RANDOM.VALUE` | `random()` | |

## 数値の精度

`NUMBER`を`NUMERIC`に変換するときの注意:

- Oracleの精度なしの`NUMBER`は桁数の制限がない。PostgreSQLの精度なしの`NUMERIC`も近いが、実装の違いがある
- できるだけ精度を明示する: `NUMBER(10,2)` → `NUMERIC(10,2)`
- 金額の計算などでは、精度の明示が必要になる移行がある（Action Itemで指摘されることがある）

## シノニム、データベースリンク、外部表

[structural-conversions.md](./structural-conversions.md#シノニム)を参照。PL/SQLのDDLにも同じ内容が当てはまる。
