-- テーブルの作成
CREATE TABLE T_0015 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    STATUS VARCHAR2(20),
    CATEGORY VARCHAR2(50),
    CREATED_DATE DATE DEFAULT SYSDATE,
    UPDATED_DATE DATE,
    DESCRIPTION CLOB,
    IS_ACTIVE NUMBER(1) DEFAULT 1
);

-- ログテーブルの作成
CREATE TABLE T_0015_LOG (
    LOG_ID NUMBER PRIMARY KEY,
    OPERATION VARCHAR2(20),
    TABLE_NAME VARCHAR2(30),
    RECORD_ID NUMBER,
    COLUMN_NAME VARCHAR2(30),
    OLD_VALUE VARCHAR2(4000),
    NEW_VALUE VARCHAR2(4000),
    CHANGE_DATE DATE DEFAULT SYSDATE,
    CHANGED_BY VARCHAR2(30)
);

-- ログシーケンスの作成
CREATE SEQUENCE T_0015_LOG_SEQ START WITH 1 INCREMENT BY 1;

-- 1. 動的SQLを使用した汎用検索プロシージャ
CREATE OR REPLACE PROCEDURE SCT_0015_DYNAMIC_SEARCH(
    p_table_name IN VARCHAR2,
    p_search_conditions IN VARCHAR2 DEFAULT NULL,
    p_order_by IN VARCHAR2 DEFAULT NULL,
    p_max_rows IN NUMBER DEFAULT 100
)
IS
    TYPE t_ref_cursor IS REF CURSOR;
    v_cursor t_ref_cursor;
    v_sql VARCHAR2(32767);
    v_column_count NUMBER;
    v_desc_tab DBMS_SQL.DESC_TAB;
    v_cursor_id PLS_INTEGER;
    v_dummy PLS_INTEGER;
    v_column_value VARCHAR2(4000);
    v_row_count NUMBER := 0;
BEGIN
    -- 動的SQLの構築
    v_sql := 'SELECT * FROM ' || p_table_name;

    IF p_search_conditions IS NOT NULL THEN
        v_sql := v_sql || ' WHERE ' || p_search_conditions;
    END IF;

    IF p_order_by IS NOT NULL THEN
        v_sql := v_sql || ' ORDER BY ' || p_order_by;
    END IF;

    v_sql := 'SELECT * FROM (' || v_sql || ') WHERE ROWNUM <= :max_rows';

    DBMS_OUTPUT.PUT_LINE('実行するSQL: ' || v_sql);

    -- DBMS_SQLを使用してカラム情報を取得
    v_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor_id, v_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_column_count, v_desc_tab);

    -- カラム名を表示
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    FOR i IN 1..v_column_count LOOP
        DBMS_OUTPUT.PUT(RPAD(v_desc_tab(i).col_name, 20));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- カーソルをクローズ（情報取得のみに使用）
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);

    -- 動的カーソルを使用してデータを取得
    OPEN v_cursor FOR v_sql USING p_max_rows;

    -- 結果を取得して表示
    LOOP
        -- 各行のデータを取得
        FETCH v_cursor INTO v_desc_tab;
        EXIT WHEN v_cursor%NOTFOUND;

        -- 各カラムの値を表示
        FOR i IN 1..v_column_count LOOP
            DBMS_OUTPUT.PUT(RPAD(NVL(TO_CHAR(v_desc_tab(i).col_name), ' '), 20));
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');

        v_row_count := v_row_count + 1;
    END LOOP;

    -- カーソルを閉じる
    CLOSE v_cursor;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('取得された行数: ' || v_row_count);

EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0015_DYNAMIC_SEARCH;
/

-- 2. 動的SQLを使用した汎用更新プロシージャ（監査ログ付き）
CREATE OR REPLACE PROCEDURE SCT_0015_DYNAMIC_UPDATE(
    p_table_name IN VARCHAR2,
    p_id_column IN VARCHAR2,
    p_id_value IN NUMBER,
    p_column_name IN VARCHAR2,
    p_new_value IN VARCHAR2,
    p_user_name IN VARCHAR2 DEFAULT USER
)
IS
    v_sql VARCHAR2(4000);
    v_old_value VARCHAR2(4000);
    v_data_type VARCHAR2(30);
    v_actual_new_value VARCHAR2(4000);
    v_rows_updated NUMBER;
BEGIN
    -- カラムのデータ型を取得
    BEGIN
        SELECT DATA_TYPE INTO v_data_type
        FROM ALL_TAB_COLUMNS
        WHERE TABLE_NAME = UPPER(p_table_name)
        AND COLUMN_NAME = UPPER(p_column_name);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'テーブルまたはカラムが存在しません: ' ||
                                   p_table_name || '.' || p_column_name);
    END;

    -- 現在の値を取得
    v_sql := 'SELECT ' || p_column_name || ' FROM ' || p_table_name ||
             ' WHERE ' || p_id_column || ' = :id';

    BEGIN
        EXECUTE IMMEDIATE v_sql INTO v_old_value USING p_id_value;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'ID ' || p_id_value || ' のレコードが見つかりません。');
    END;

    -- データ型に基づいて更新SQLを構築
    v_sql := 'UPDATE ' || p_table_name || ' SET ' || p_column_name || ' = ';

    IF v_data_type IN ('VARCHAR2', 'CHAR', 'VARCHAR', 'CLOB', 'NVARCHAR2', 'NCHAR') THEN
        v_sql := v_sql || ':new_value';
        v_actual_new_value := p_new_value;
    ELSIF v_data_type IN ('NUMBER', 'FLOAT', 'INTEGER', 'DECIMAL') THEN
        v_sql := v_sql || 'TO_NUMBER(:new_value)';
        v_actual_new_value := p_new_value;
    ELSIF v_data_type = 'DATE' THEN
        v_sql := v_sql || 'TO_DATE(:new_value, ''YYYY-MM-DD'')';
        v_actual_new_value := p_new_value;
    ELSIF v_data_type LIKE 'TIMESTAMP%' THEN
        v_sql := v_sql || 'TO_TIMESTAMP(:new_value, ''YYYY-MM-DD HH24:MI:SS.FF'')';
        v_actual_new_value := p_new_value;
    ELSE
        v_sql := v_sql || ':new_value';
        v_actual_new_value := p_new_value;
    END IF;

    v_sql := v_sql || ' WHERE ' || p_id_column || ' = :id';

    -- 更新を実行
    EXECUTE IMMEDIATE v_sql USING v_actual_new_value, p_id_value;

    -- 影響を受けた行数を取得
    v_rows_updated := SQL%ROWCOUNT;

    -- 監査ログに記録
    INSERT INTO T_0015_LOG (
        LOG_ID, OPERATION, TABLE_NAME, RECORD_ID,
        COLUMN_NAME, OLD_VALUE, NEW_VALUE, CHANGED_BY
    ) VALUES (
        T_0015_LOG_SEQ.NEXTVAL, 'UPDATE', p_table_name, p_id_value,
        p_column_name, v_old_value, p_new_value, p_user_name
    );

    DBMS_OUTPUT.PUT_LINE('更新が完了しました。影響を受けた行数: ' || v_rows_updated);
    DBMS_OUTPUT.PUT_LINE('テーブル: ' || p_table_name);
    DBMS_OUTPUT.PUT_LINE('ID: ' || p_id_value);
    DBMS_OUTPUT.PUT_LINE('カラム: ' || p_column_name);
    DBMS_OUTPUT.PUT_LINE('旧値: ' || v_old_value);
    DBMS_OUTPUT.PUT_LINE('新値: ' || p_new_value);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0015_DYNAMIC_UPDATE;
/
