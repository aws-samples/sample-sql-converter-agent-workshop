CREATE OR REPLACE FUNCTION SCT_0036_create_binary_id (
    p_prefix IN VARCHAR2,
    p_id IN NUMBER,
    p_suffix IN VARCHAR2
) RETURN RAW IS
    v_prefix_raw RAW(100);
    v_id_raw RAW(100);
    v_suffix_raw RAW(100);
    v_result RAW(2000);
BEGIN
    -- 各部分をRAWに変換
    v_prefix_raw := UTL_RAW.CAST_TO_RAW(p_prefix);
    v_id_raw := UTL_RAW.CAST_TO_RAW(TO_CHAR(p_id, '0000000'));
    v_suffix_raw := UTL_RAW.CAST_TO_RAW(p_suffix);

    -- 各部分を連結
    v_result := UTL_RAW.CONCAT(v_prefix_raw, v_id_raw, v_suffix_raw);

    RETURN v_result;
END;
/
CREATE OR REPLACE FUNCTION SCT_0036_fetch_web_content (
    p_url IN VARCHAR2
) RETURN CLOB IS
    v_request UTL_HTTP.REQ;
    v_response UTL_HTTP.RESP;
    v_buffer VARCHAR2(32767);
    v_content CLOB;
BEGIN
    -- Oracle固有のUTL_HTTPパッケージを使用
    DBMS_LOB.CREATETEMPORARY(v_content, TRUE);

    v_request := UTL_HTTP.BEGIN_REQUEST(p_url);
    v_response := UTL_HTTP.GET_RESPONSE(v_request);

    BEGIN
        LOOP
            UTL_HTTP.READ_TEXT(v_response, v_buffer);
            DBMS_LOB.APPEND(v_content, v_buffer);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
            UTL_HTTP.END_RESPONSE(v_response);
    END;

    RETURN v_content;
END;
/
CREATE TABLE t_0036_employees
(employee_id NUMBER
,employee_name VARCHAR2(100)
,manager_id  NUMBER)
/

CREATE OR REPLACE FUNCTION SCT_0036_get_employee_hierarchy (
    p_emp_id IN NUMBER
) RETURN SYS_REFCURSOR IS
    v_result SYS_REFCURSOR;
BEGIN
    -- Oracle固有のCONNECT BY句を使用した階層クエリ
    OPEN v_result FOR
        SELECT employee_id, employee_name, manager_id, LEVEL as hierarchy_level
        FROM t_0036_employees
        START WITH employee_id = p_emp_id
        CONNECT BY PRIOR employee_id = manager_id
        ORDER SIBLINGS BY employee_name;

    RETURN v_result;
END;
/
CREATE OR REPLACE FUNCTION SCT_0036_get_file_content (
    p_directory IN VARCHAR2,
    p_filename IN VARCHAR2
) RETURN CLOB IS
    v_file BFILE;
    v_dest CLOB;
    v_dest_offset INTEGER := 1;
    v_src_offset INTEGER := 1;
    v_lang_context INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
    v_warning INTEGER;
BEGIN
    -- Oracle固有のDBMS_LOBパッケージを使用
    v_file := BFILENAME(p_directory, p_filename);
    DBMS_LOB.FILEOPEN(v_file, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.CREATETEMPORARY(v_dest, TRUE);

    DBMS_LOB.LOADCLOBFROMFILE(
        dest_lob     => v_dest,
        src_bfile    => v_file,
        amount       => DBMS_LOB.GETLENGTH(v_file),
        dest_offset  => v_dest_offset,
        src_offset   => v_src_offset,
        bfile_csid   => DBMS_LOB.DEFAULT_CSID,
        lang_context => v_lang_context,
        warning      => v_warning
    );

    DBMS_LOB.FILECLOSE(v_file);
    RETURN v_dest;
END;
/
CREATE TABLE SCT_0036_remote_table (id NUMBER, data_value VARCHAR2(1000))
/

CREATE DATABASE LINK SCT_0036_remote_db_link
  CONNECT TO &1 IDENTIFIED BY &2
  USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=&3)(PORT=&4))
  (CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=&5)))'
/

CREATE OR REPLACE FUNCTION SCT_0036_get_remote_data (
    p_id IN NUMBER
) RETURN VARCHAR2 IS
    v_result VARCHAR2(1000);
BEGIN
    -- Oracle固有のデータベースリンク構文を使用
    SELECT data_value INTO v_result
    FROM SCT_0036_remote_table@SCT_0036_remote_db_link
    WHERE id = p_id;

    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/
CREATE OR REPLACE FUNCTION SCT_0036_get_session_info RETURN VARCHAR2 IS
    v_info VARCHAR2(4000);
BEGIN
    -- Oracle固有のSYS_CONTEXT関数を使用
    v_info := 'User: ' || SYS_CONTEXT('USERENV', 'SESSION_USER') ||
              ', IP: ' || SYS_CONTEXT('USERENV', 'IP_ADDRESS') ||
              ', Terminal: ' || SYS_CONTEXT('USERENV', 'TERMINAL') ||
              ', DB Name: ' || SYS_CONTEXT('USERENV', 'DB_NAME');

    RETURN v_info;
END;
/
