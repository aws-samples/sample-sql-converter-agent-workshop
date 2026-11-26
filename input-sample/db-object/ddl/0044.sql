CREATE OR REPLACE PROCEDURE SCT_0044_concat_raw_example (
    p_text1 IN VARCHAR2,
    p_text2 IN VARCHAR2
) AS
    v_raw1 RAW(100);
    v_raw2 RAW(100);
    v_result RAW(200);
    v_text1 VARCHAR2(4000);
BEGIN
    -- 入力文字列をRAWに変換
    SELECT UTL_RAW.CAST_TO_RAW(p_text1) INTO v_raw1 FROM DUAL;
    SELECT UTL_RAW.CAST_TO_RAW(p_text2) INTO v_raw2 FROM DUAL;

    -- UTL_RAW.CONCATを使用して連結
    SELECT UTL_RAW.CONCAT(v_raw1, v_raw2) INTO v_result FROM DUAL;

    -- 結果を表示
    DBMS_OUTPUT.PUT_LINE('RAW1: ' || v_raw1);
    DBMS_OUTPUT.PUT_LINE('RAW2: ' || v_raw2);
    DBMS_OUTPUT.PUT_LINE('連結結果 (RAW): ' || v_result);

    -- RAWを文字列に戻す
    SELECT UTL_RAW.CAST_TO_VARCHAR2(v_result) INTO v_text1 FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('連結結果 (文字列): ' || v_text1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
