CREATE TABLE T_0076 (
    ID NUMBER PRIMARY KEY,
    FILENAME VARCHAR2(255),
    CONTENT CLOB,
    CREATED_DATE DATE DEFAULT SYSDATE,
    UPDATED_DATE DATE DEFAULT SYSDATE
);

CREATE OR REPLACE PROCEDURE SCT_0076_READ_FILE (
    p_directory_name IN VARCHAR2,
    p_file_name IN VARCHAR2
) AS
    v_file UTL_FILE.FILE_TYPE;
    v_line VARCHAR2(32767);
    v_content CLOB := '';
    v_file_id NUMBER;
BEGIN
    -- ディレクトリが存在するか確認
    IF NOT UTL_FILE.IS_OPEN(v_file) THEN
        -- ファイルを開く
        v_file := UTL_FILE.FOPEN(p_directory_name, p_file_name, 'R');
    END IF;

    -- 新しいIDを生成
    SELECT NVL(MAX(ID), 0) + 1 INTO v_file_id FROM T_0076;

    -- ファイルの内容を読み込む
    BEGIN
        LOOP
            UTL_FILE.GET_LINE(v_file, v_line);
            v_content := v_content || v_line || CHR(10);
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- ファイルの終わりに達した
    END;

    -- ファイルを閉じる
    UTL_FILE.FCLOSE(v_file);

    -- テーブルにデータを挿入
    INSERT INTO T_0076 (ID, FILENAME, CONTENT, CREATED_DATE, UPDATED_DATE)
    VALUES (v_file_id, p_file_name, v_content, SYSDATE, SYSDATE);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('ファイル ' || p_file_name || ' を読み込み、テーブルに保存しました。');
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(v_file) THEN
            UTL_FILE.FCLOSE(v_file);
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0076_READ_FILE;
/

CREATE OR REPLACE PROCEDURE SCT_0076_WRITE_FILE (
    p_directory_name IN VARCHAR2,
    p_file_name IN VARCHAR2,
    p_id IN NUMBER
) AS
    v_file UTL_FILE.FILE_TYPE;
    v_content CLOB;
    v_buffer VARCHAR2(32767);
    v_position INTEGER := 1;
    v_chunk_size INTEGER := 32767;
    v_content_length INTEGER;
BEGIN
    -- テーブルからデータを取得
    SELECT CONTENT INTO v_content
    FROM T_0076
    WHERE ID = p_id;

    v_content_length := DBMS_LOB.GETLENGTH(v_content);

    -- ファイルを書き込みモードで開く
    v_file := UTL_FILE.FOPEN(p_directory_name, p_file_name, 'W');

    -- CLOBの内容をファイルに書き込む
    WHILE v_position <= v_content_length LOOP
        v_buffer := DBMS_LOB.SUBSTR(v_content, LEAST(v_chunk_size, v_content_length - v_position + 1), v_position);
        UTL_FILE.PUT_LINE(v_file, v_buffer);
        v_position := v_position + v_chunk_size;
    END LOOP;

    -- ファイルを閉じる
    UTL_FILE.FCLOSE(v_file);

    DBMS_OUTPUT.PUT_LINE('ID ' || p_id || ' のデータをファイル ' || p_file_name || ' に書き込みました。');
EXCEPTION
    WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN(v_file) THEN
            UTL_FILE.FCLOSE(v_file);
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0076_WRITE_FILE;
/
