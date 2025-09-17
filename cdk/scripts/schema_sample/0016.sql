-- テーブルの作成
CREATE TABLE T_0016 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

CREATE OR REPLACE PROCEDURE SCT_0016_DYNAMIC_BULK_COLLECT(
    p_condition IN VARCHAR2 DEFAULT NULL,
    p_batch_size IN NUMBER DEFAULT 10
)
IS
    -- 動的SQLの結果を格納するためのレコード型とコレクション型を定義
    TYPE t_record IS RECORD (
        id NUMBER,
        name VARCHAR2(100),
        value NUMBER,
        created_date DATE
    );
    TYPE t_record_table IS TABLE OF t_record;

    -- データを格納するコレクション
    v_records t_record_table;

    -- 動的SQL文を格納する変数
    v_sql VARCHAR2(4000);

    -- 処理した行数を格納する変数
    v_row_count PLS_INTEGER;
    v_total_rows PLS_INTEGER := 0;
BEGIN
    -- SQL文を構築
    v_sql := 'SELECT ID, NAME, VALUE, CREATED_DATE FROM T_0016';
    IF p_condition IS NOT NULL THEN
        v_sql := v_sql || ' WHERE ' || p_condition;
    END IF;

    DBMS_OUTPUT.PUT_LINE('実行するSQL: ' || v_sql);

    -- BULK COLLECTを使用してデータを一括取得
    EXECUTE IMMEDIATE v_sql BULK COLLECT INTO v_records;

    v_row_count := v_records.COUNT;
    DBMS_OUTPUT.PUT_LINE('取得した行数: ' || v_row_count);

    -- バッチサイズごとに処理
    FOR i IN 0..CEIL(v_row_count/p_batch_size)-1 LOOP
        DBMS_OUTPUT.PUT_LINE('===== バッチ ' || (i+1) || ' =====');

        -- バッチ内のレコードを処理
        FOR j IN 1..LEAST(p_batch_size, v_row_count-i*p_batch_size) LOOP
            v_total_rows := v_total_rows + 1;
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || v_records(i*p_batch_size+j).id ||
                ', NAME: ' || v_records(i*p_batch_size+j).name ||
                ', VALUE: ' || v_records(i*p_batch_size+j).value ||
                ', DATE: ' || TO_CHAR(v_records(i*p_batch_size+j).created_date, 'YYYY-MM-DD')
            );
        END LOOP;
    END LOOP;

    -- 処理の統計情報を表示
    DBMS_OUTPUT.PUT_LINE('処理完了: 合計 ' || v_total_rows || ' 行を処理しました');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0016_DYNAMIC_BULK_COLLECT;
/
