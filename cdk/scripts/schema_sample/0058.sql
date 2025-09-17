CREATE OR REPLACE PROCEDURE SCT_0058_get_transaction_id AS
    v_trans_id VARCHAR2(100);
BEGIN
    -- 現在のトランザクションIDを取得
    v_trans_id := DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(TRUE);

    -- トランザクションIDを表示
    IF v_trans_id IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('現在のトランザクションID: ' || v_trans_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('アクティブなトランザクションはありません');

        -- トランザクションを開始するためのダミー操作
        EXECUTE IMMEDIATE 'UPDATE dual SET dummy = dummy WHERE rownum = 0';

        -- 再度トランザクションIDを取得
        v_trans_id := DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(TRUE);
        DBMS_OUTPUT.PUT_LINE('新しいトランザクションID: ' || v_trans_id);
    END IF;
END;
/
