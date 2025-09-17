CREATE OR REPLACE PROCEDURE SCT_0073_create_complex_index (
    p_table_name IN VARCHAR2,
    p_index_name IN VARCHAR2
) AS
    v_sql VARCHAR2(4000);
    v_exists NUMBER;
BEGIN
    -- テーブルが存在するか確認
    SELECT COUNT(*) INTO v_exists FROM DUAL
    WHERE EXISTS (SELECT 1 FROM user_tables WHERE table_name = UPPER(p_table_name));

    IF v_exists = 0 THEN
        -- テスト用のテーブルを作成
        EXECUTE IMMEDIATE 'CREATE TABLE ' || p_table_name || ' (' ||
                         'id NUMBER, ' ||
                         'name VARCHAR2(100), ' ||
                         'description VARCHAR2(4000))';
    END IF;

    -- Oracle固有のインデックスタイプを作成
    v_sql := 'CREATE BITMAP INDEX ' || p_index_name || ' ON ' || p_table_name || '(name) ' ||
             'TABLESPACE users ' ||
             'NOLOGGING ' ||
             'COMPRESS 2 ' ||
             'PARALLEL 4';

    EXECUTE IMMEDIATE v_sql;

    -- 確認メッセージ
    SELECT 'インデックス ' || p_index_name || ' が作成されました' INTO v_sql FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(v_sql);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0073_create_dynamic_table (
    p_table_name IN VARCHAR2,
    p_column_name IN VARCHAR2
) AS
    v_sql VARCHAR2(4000);
BEGIN
    -- 動的にテーブルを作成するDDL
    v_sql := 'CREATE TABLE ' || p_table_name || ' (' ||
             p_column_name || ' VARCHAR2(100))';

    -- 動的DDLを実行
    EXECUTE IMMEDIATE v_sql;

    -- 確認メッセージ
    SELECT 'テーブル ' || p_table_name || ' が作成されました' INTO v_sql FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(v_sql);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0073_create_materialized_view (
    p_mview_name IN VARCHAR2
) AS
    v_sql VARCHAR2(4000);
    v_dummy VARCHAR2(100);
BEGIN
    -- Oracle固有のマテリアライズドビュー作成
    v_sql := 'CREATE MATERIALIZED VIEW ' || p_mview_name || ' ' ||
             'BUILD IMMEDIATE ' ||
             'REFRESH FAST ON COMMIT ' ||
             'ENABLE QUERY REWRITE ' ||
             'AS ' ||
             'SELECT ''X'' AS dummy FROM DUAL';

    EXECUTE IMMEDIATE v_sql;

    -- マテリアライズドビューログの作成
    v_sql := 'CREATE MATERIALIZED VIEW LOG ON DUAL ' ||
             'WITH ROWID, SEQUENCE, PRIMARY KEY ' ||
             'INCLUDING NEW VALUES';

    EXECUTE IMMEDIATE v_sql;

    -- 確認メッセージ
    SELECT 'マテリアライズドビュー ' || p_mview_name || ' が作成されました' INTO v_dummy FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(v_dummy);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0073_create_partitioned_table (
    p_table_name IN VARCHAR2
) AS
    v_sql VARCHAR2(4000);
    v_dummy VARCHAR2(100);
BEGIN
    -- Oracle固有のパーティショニングを使用したテーブル作成
    v_sql := 'CREATE TABLE ' || p_table_name || ' (' ||
             'id NUMBER, ' ||
             'trans_date DATE, ' ||
             'amount NUMBER(10,2), ' ||
             'description VARCHAR2(200)' ||
             ') ' ||
             'PARTITION BY RANGE (trans_date) ' ||
             'INTERVAL(NUMTOYMINTERVAL(1, ''MONTH'')) ' ||
             'STORE IN (users) ' ||
             '(' ||
             'PARTITION p_start VALUES LESS THAN (TO_DATE(''2023-01-01'', ''YYYY-MM-DD''))' ||
             ')';

    EXECUTE IMMEDIATE v_sql;

    -- 確認メッセージ
    SELECT 'パーティションテーブル ' || p_table_name || ' が作成されました' INTO v_dummy FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(v_dummy);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0073_create_table_with_oracle_features (
    p_table_name IN VARCHAR2
) AS
    v_sql VARCHAR2(4000);
    v_count NUMBER;
BEGIN
    -- テーブルが存在するか確認
    SELECT COUNT(*) INTO v_count FROM DUAL
    WHERE EXISTS (SELECT 1 FROM user_tables WHERE table_name = UPPER(p_table_name));

    IF v_count > 0 THEN
        -- テーブルが存在する場合は削除
        EXECUTE IMMEDIATE 'DROP TABLE ' || p_table_name || ' PURGE';
    END IF;

    -- Oracle固有の機能を使用したテーブル作成
    v_sql := 'CREATE TABLE ' || p_table_name || ' (' ||
             'id NUMBER GENERATED ALWAYS AS IDENTITY, ' ||
             'name VARCHAR2(100), ' ||
             'created_date DATE DEFAULT SYSDATE, ' ||
             'data BLOB, ' ||
             'CONSTRAINT ' || p_table_name || '_pk PRIMARY KEY (id) ' ||
             ') ' ||
             'ORGANIZATION INDEX ' ||
             'TABLESPACE users ' ||
             'STORAGE (INITIAL 1M NEXT 1M) ' ||
             'LOGGING ' ||
             'MONITORING';

    EXECUTE IMMEDIATE v_sql;

    -- 確認メッセージ
    SELECT 'テーブル ' || p_table_name || ' が作成されました' INTO v_sql FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(v_sql);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
