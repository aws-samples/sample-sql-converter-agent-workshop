CREATE TABLE T_0037 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    UPDATE_DATE DATE
);

CREATE OR REPLACE FUNCTION SCT_0037_UPDATE_WITH_COMMIT(
    p_id IN NUMBER,
    p_new_value IN NUMBER
) RETURN NUMBER
IS
    v_result NUMBER := 0;
BEGIN
    -- トランザクションに名前を設定
    SET TRANSACTION NAME 'tx-1';

    -- 更新処理
    UPDATE T_0037
    SET VALUE = p_new_value,
        UPDATE_DATE = SYSDATE
    WHERE ID = p_id;

    -- 影響を受けた行数を取得
    v_result := SQL%ROWCOUNT;

    -- 明示的にコミット
    COMMIT;

    RETURN v_result;
END SCT_0037_UPDATE_WITH_COMMIT;
/
