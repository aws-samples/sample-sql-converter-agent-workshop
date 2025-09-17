CREATE OR REPLACE PROCEDURE SCT_0043_complex_dynamic_sql (
    p_expression IN VARCHAR2
) AS
    v_sql VARCHAR2(4000);
    v_cursor_id INTEGER;
    v_result VARCHAR2(4000);
    v_cols DBMS_SQL.DESC_TAB;
    v_col_cnt NUMBER;
BEGIN
    -- 複雑なダイナミックSQL文を構築
    v_sql := 'SELECT ' || p_expression || ' FROM DUAL';

    -- DBMS_SQLを使用して動的SQLを実行
    v_cursor_id := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor_id, v_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_cnt, v_cols);

    -- 結果列を定義
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_result, 4000);

    -- 実行して結果を取得
    IF DBMS_SQL.EXECUTE(v_cursor_id) > 0 THEN
        IF DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_result);
        END IF;
    END IF;

    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);

    DBMS_OUTPUT.PUT_LINE('結果: ' || v_result);
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        RAISE;
END;
/
CREATE OR REPLACE PROCEDURE SCT_0043_complex_raw_operations (
    p_input1 IN VARCHAR2,
    p_input2 IN VARCHAR2
) AS
    v_raw1 RAW(100);
    v_raw2 RAW(100);
    v_result RAW(200);
    v_bit_and RAW(100);
    v_bit_or RAW(100);
    v_bit_xor RAW(100);
    v_bit_not RAW(100);
    v_hex_result VARCHAR2(400);
BEGIN
    -- 入力をRAWに変換
    SELECT UTL_RAW.CAST_TO_RAW(p_input1), UTL_RAW.CAST_TO_RAW(p_input2)
    INTO v_raw1, v_raw2 FROM DUAL;

    -- 複雑なRAW操作
    SELECT UTL_RAW.CONCAT(
               UTL_RAW.SUBSTR(v_raw1, 1, 3),
               UTL_RAW.OVERLAY(
                   v_raw2,
                   v_raw1,
                   1,
                   UTL_RAW.LENGTH(v_raw2)
               ),
               UTL_RAW.COPIES(HEXTORAW('A5'), 3)
           ),
           UTL_RAW.BIT_AND(v_raw1, v_raw2),
           UTL_RAW.BIT_OR(v_raw1, v_raw2),
           UTL_RAW.BIT_XOR(v_raw1, v_raw2),
           UTL_RAW.BIT_COMPLEMENT(v_raw1)
    INTO v_result, v_bit_and, v_bit_or, v_bit_xor, v_bit_not
    FROM DUAL;

    -- 結果を16進数に変換
    SELECT RAWTOHEX(v_result) INTO v_hex_result FROM DUAL;

    -- 結果を表示
    DBMS_OUTPUT.PUT_LINE('RAW1: ' || v_raw1);
    DBMS_OUTPUT.PUT_LINE('RAW2: ' || v_raw2);
    DBMS_OUTPUT.PUT_LINE('結果 (RAW): ' || v_result);
    DBMS_OUTPUT.PUT_LINE('結果 (HEX): ' || v_hex_result);
    DBMS_OUTPUT.PUT_LINE('BIT_AND: ' || v_bit_and);
    DBMS_OUTPUT.PUT_LINE('BIT_OR: ' || v_bit_or);
    DBMS_OUTPUT.PUT_LINE('BIT_XOR: ' || v_bit_xor);
    DBMS_OUTPUT.PUT_LINE('BIT_NOT: ' || v_bit_not);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0043_labeled_blocks_with_goto (
    p_max_count IN NUMBER
) AS
    v_counter NUMBER := 0;
    v_result VARCHAR2(100);
BEGIN
    <<outer_block>>
    BEGIN
        v_counter := 0;

        <<inner_loop>>
        LOOP
            v_counter := v_counter + 1;

            SELECT TO_CHAR(v_counter) INTO v_result FROM DUAL;

            BEGIN
                IF MOD(v_counter, 3) = 0 THEN
                    GOTO skip_output;
                END IF;

                DBMS_OUTPUT.PUT_LINE('カウンター: ' || v_result);

                <<skip_output>>
                NULL;

                EXIT inner_loop WHEN(v_counter >= p_max_count);
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('内部エラー: ' || SQLERRM);
                    GOTO continue_loop;
            END;

            <<continue_loop>>
            NULL;
        END LOOP inner_loop;
    END outer_block;

    DBMS_OUTPUT.PUT_LINE('処理完了');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('外部エラー: ' || SQLERRM);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0043_pragma_heavy_procedure (
    p_input IN VARCHAR2
) AS
    e_custom_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_custom_exception, -20001);

    -- 非標準のプラグマ
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_result VARCHAR2(4000);
BEGIN
    -- DUALテーブルを使用した単純なクエリ
    SELECT UPPER(p_input) INTO v_result FROM DUAL;

    -- 複雑な例外処理ブロック
    BEGIN
        IF v_result IS NULL THEN
            RAISE e_custom_exception;
        END IF;

    EXCEPTION
        WHEN e_custom_exception THEN
            RAISE_APPLICATION_ERROR(-20001, '入力が無効です');
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20999 AND -20000 THEN
                RAISE;
            ELSE
                RAISE_APPLICATION_ERROR(-20002, 'その他のエラー: ' || SQLERRM);
            END IF;
    END;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('処理結果: ' || v_result);
END;
/
CREATE OR REPLACE PROCEDURE SCT_0043_xml_processing (
    p_input IN VARCHAR2
) AS
    v_xml XMLTYPE;
    v_result VARCHAR2(4000);
    v_node_value VARCHAR2(1000);
BEGIN
    -- 入力文字列からXMLを作成
    SELECT XMLTYPE('<root><item>' || p_input || '</item></root>') INTO v_xml FROM DUAL;

    -- XMLPath関数を使用
    SELECT XMLCAST(XMLQUERY('/root/item/text()' PASSING v_xml RETURNING CONTENT) AS VARCHAR2(1000))
    INTO v_node_value FROM DUAL;

    -- XMLElement関数を使用して新しいXMLを作成
    SELECT XMLSERIALIZE(CONTENT XMLELEMENT("result",
               XMLATTRIBUTES(SYSDATE AS "timestamp"),
               XMLELEMENT("value", v_node_value),
               XMLELEMENT("processed_by", USER)
           ) AS CLOB)
    INTO v_result FROM DUAL;

    DBMS_OUTPUT.PUT_LINE('XML結果: ' || v_result);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
