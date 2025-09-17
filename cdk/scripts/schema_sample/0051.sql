CREATE OR REPLACE PROCEDURE SCT_0051_get_error_message(
    p_error_code IN NUMBER
) AS
    v_error_message VARCHAR2(4000);
BEGIN
    -- 指定されたエラーコードのエラーメッセージを取得
    v_error_message := SQLERRM(p_error_code);

    -- 結果を表示
    DBMS_OUTPUT.PUT_LINE('エラーコード: ' || p_error_code);
    DBMS_OUTPUT.PUT_LINE('エラーメッセージ: ' || v_error_message);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('プロシージャ実行中にエラーが発生しました: ' || SQLERRM(p_error_code));
END SCT_0051_get_error_message;
/
