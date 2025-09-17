-- テーブルの作成
CREATE TABLE T_0007 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100) NOT NULL,
    VALUE NUMBER CHECK (VALUE >= 0),
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- RAISE_APPLICATION_ERRORを使用したシンプルなプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0007_INSERT_RECORD(
    p_id IN NUMBER,
    p_name IN VARCHAR2,
    p_value IN NUMBER
)
IS
BEGIN
    -- 入力値の検証
    IF p_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'IDを指定してください。', TRUE);
    END IF;

    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '名前を指定してください。', TRUE);
    END IF;

    IF p_value IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, '値を指定してください。', TRUE);
    END IF;

    IF p_value < 0 THEN
        RAISE_APPLICATION_ERROR(-20004, '値は0以上である必要があります。', FALSE);
    END IF;

    -- レコードの挿入
    INSERT INTO T_0007 (ID, NAME, VALUE, CREATED_DATE)
    VALUES (p_id, p_name, p_value, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('レコードが正常に挿入されました。ID: ' || p_id);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20005, 'ID ' || p_id || ' は既に存在します。', TRUE);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'エラーが発生しました: ' || SQLERRM, FALSE);
END SCT_0007_INSERT_RECORD;
/
