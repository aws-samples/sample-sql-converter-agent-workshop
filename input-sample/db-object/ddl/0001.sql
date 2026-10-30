CREATE OR REPLACE PROCEDURE SCT_0001_calculate_time_difference (
    p_start_date IN TIMESTAMP,
    p_end_date IN TIMESTAMP
) AS
    v_interval INTERVAL DAY TO SECOND;  -- この特定のINTERVAL型の使用方法がPostgreSQLと互換性がない場合がある
BEGIN
    v_interval := p_end_date - p_start_date;
    DBMS_OUTPUT.PUT_LINE('Time difference: ' || v_interval);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0001_combined_types_example (
    p_row_id IN UROWID,
    p_name IN VARCHAR,
    p_type_code IN CHARACTER,
    p_dec IN DEC,
    p_any IN ANYDATA
) AS
    v_result VARCHAR(500);
    v_type_desc CHARACTER(20);
BEGIN
    -- 型コードに基づいて説明を設定
    CASE p_type_code
        WHEN 'A' THEN v_type_desc := 'Type A            ';
        WHEN 'B' THEN v_type_desc := 'Type B            ';
        ELSE v_type_desc := 'Unknown           ';
    END CASE;

    -- 結果の組み立て
    v_result := 'ID: ' || p_row_id || ', Name: ' || p_name || ', Type: ' || v_type_desc;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('処理結果: ' || v_result);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0001_process_file_data (
    p_directory IN VARCHAR2,
    p_filename IN VARCHAR2
) AS
    v_file BFILE;  -- BFILE型はPostgreSQLに直接対応するものがない
    v_content BLOB;
BEGIN
    v_file := BFILENAME(p_directory, p_filename);
    DBMS_LOB.FILEOPEN(v_file, DBMS_LOB.FILE_READONLY);
    -- ファイル処理ロジック
    DBMS_LOB.FILECLOSE(v_file);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0001_process_nested_table AS
    TYPE item_list_type IS TABLE OF VARCHAR2(100);  -- ネストテーブル型
    v_items item_list_type;
BEGIN
    v_items := item_list_type('Item1', 'Item2', 'Item3');

    FOR i IN 1..v_items.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Item ' || i || ': ' || v_items(i));
    END LOOP;
END;
/
CREATE OR REPLACE PROCEDURE SCT_0001_process_xml_data (
    p_xml_data IN XMLType  -- XMLTypeの特定の使用方法がPostgreSQLと互換性がない場合がある
) AS
    v_value VARCHAR2(100);
BEGIN
    SELECT EXTRACTVALUE(p_xml_data, '/root/element') INTO v_value FROM dual;
    DBMS_OUTPUT.PUT_LINE('Extracted value: ' || v_value);
END;
/
CREATE TABLE SCT_0001_combine_type (
	C1 VARCHAR(1),
	C2 CHARACTER(1),
	C3 ANYDATA,
	C4 DEC(1,0),
	C5 DECIMAL(1,0))
/
CREATE OR REPLACE PROCEDURE SCT_0001_update_by_rowid (
    p_table_name IN VARCHAR2,
    p_row_id IN ROWID,  -- ROWID型はPostgreSQLに直接対応するものがない
    p_new_value IN VARCHAR2
) AS
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'UPDATE ' || p_table_name || ' SET some_column = :1 WHERE ROWID = :2';
    EXECUTE IMMEDIATE v_sql USING p_new_value, p_row_id;
END;
/
