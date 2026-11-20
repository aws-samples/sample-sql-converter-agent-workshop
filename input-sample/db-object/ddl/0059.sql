CREATE OR REPLACE PROCEDURE SCT_0059_DYNAMIC_SQL_WITH_BIND(
    p_expression IN VARCHAR2,
    p_bind_value IN VARCHAR2
)
IS
    v_cursor_id INTEGER;
    v_rows_processed INTEGER;
    v_sql VARCHAR2(4000);
    v_result VARCHAR2(4000);
BEGIN
    -- 動的SQLの文字列を構築（バインド変数を使用）
    v_sql := 'SELECT ' || p_expression || ' FROM DUAL WHERE :bind_param IS NOT NULL';

    DBMS_OUTPUT.PUT_LINE('実行するSQL: ' || v_sql);
    DBMS_OUTPUT.PUT_LINE('バインド値: ' || p_bind_value);

    -- カーソルをオープン
    v_cursor_id := DBMS_SQL.OPEN_CURSOR;

    -- SQLをパース
    DBMS_SQL.PARSE(v_cursor_id, v_sql, DBMS_SQL.NATIVE);

    -- バインド変数を設定
    DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':bind_param', p_bind_value);

    -- 出力変数を定義
    DBMS_SQL.DEFINE_COLUMN(v_cursor_id, 1, v_result, 4000);

    -- SQLを実行
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursor_id);

    -- 結果を取得
    IF DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(v_cursor_id, 1, v_result);
        DBMS_OUTPUT.PUT_LINE('計算結果: ' || v_result);
    END IF;

    -- カーソルをクローズ
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);

EXCEPTION
    WHEN OTHERS THEN
        -- エラーが発生した場合はカーソルをクローズ
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0059_DYNAMIC_SQL_WITH_BIND;
/
