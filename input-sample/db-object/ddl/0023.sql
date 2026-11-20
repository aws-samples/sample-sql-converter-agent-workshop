-- テーブルの作成
CREATE TABLE T_0023 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    STATUS VARCHAR2(20),
    VALUE NUMBER,
    LAST_UPDATED DATE
);

CREATE OR REPLACE PROCEDURE SCT_0023_PROCESS_WITH_LOCK(
    p_id IN NUMBER,
    p_increment IN NUMBER DEFAULT 100,
    p_lock_mode IN NUMBER DEFAULT 0  -- 0: デフォルト, 1: NOWAIT, 2: WAIT 5秒, 3: WAIT 10秒
)
IS
    v_name VARCHAR2(100);
    v_value NUMBER;
    v_status VARCHAR2(20);
BEGIN
    -- SELECT FOR UPDATEを使用してレコードをロック
    BEGIN
        CASE p_lock_mode
            WHEN 1 THEN
                -- NOWAITオプション
                SELECT NAME, VALUE, STATUS
                INTO v_name, v_value, v_status
                FROM T_0023
                WHERE ID = p_id
                FOR UPDATE NOWAIT;

                DBMS_OUTPUT.PUT_LINE('レコードをNOWAITオプションでロックしました。');

            WHEN 2 THEN
                -- WAIT 5秒
                SELECT NAME, VALUE, STATUS
                INTO v_name, v_value, v_status
                FROM T_0023
                WHERE ID = p_id
                FOR UPDATE WAIT 5;

                DBMS_OUTPUT.PUT_LINE('レコードをWAIT 5秒オプションでロックしました。');

            WHEN 3 THEN
                -- WAIT 10秒
                SELECT NAME, VALUE, STATUS
                INTO v_name, v_value, v_status
                FROM T_0023
                WHERE ID = p_id
                FOR UPDATE WAIT 10;

                DBMS_OUTPUT.PUT_LINE('レコードをWAIT 10秒オプションでロックしました。');

            ELSE
                -- デフォルト：無期限に待機
                SELECT NAME, VALUE, STATUS
                INTO v_name, v_value, v_status
                FROM T_0023
                WHERE ID = p_id
                FOR UPDATE;

                DBMS_OUTPUT.PUT_LINE('レコードをデフォルトオプションでロックしました。');
        END CASE;

        -- 以下は同じ処理を続ける...
        DBMS_OUTPUT.PUT_LINE('ID: ' || p_id || ', 名前: ' || v_name ||
                           ', 値: ' || v_value || ', 状態: ' || v_status);

        UPDATE T_0023
        SET VALUE = v_value + p_increment,
            LAST_UPDATED = SYSDATE
        WHERE ID = p_id;

        DBMS_OUTPUT.PUT_LINE('値を ' || v_value || ' から ' || (v_value + p_increment) || ' に更新しました。');

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('トランザクションをコミットしました。');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ID ' || p_id || ' のレコードが見つかりませんでした。');
            ROLLBACK;

        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
            ROLLBACK;
    END;
END SCT_0023_PROCESS_WITH_LOCK;
/
