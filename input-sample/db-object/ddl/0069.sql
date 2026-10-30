-- テーブルの作成
CREATE TABLE T_0069 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- ログテーブルの作成
CREATE TABLE T_0069_LOG (
    LOG_ID NUMBER PRIMARY KEY,
    OPERATION VARCHAR2(10),
    TABLE_NAME VARCHAR2(30),
    RECORD_ID NUMBER,
    LOG_DATE DATE DEFAULT SYSDATE
);

-- シーケンスの作成
CREATE SEQUENCE T_0069_LOG_SEQ START WITH 1 INCREMENT BY 1;

-- カーソル変数を使用した自律トランザクションプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0069_PROCESS_WITH_CURSOR(
    p_id IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    -- ログを記録
    INSERT INTO T_0069_LOG (LOG_ID, OPERATION, TABLE_NAME, RECORD_ID)
    VALUES (T_0069_LOG_SEQ.NEXTVAL, 'SELECT', 'T_0069', p_id);

    -- 自律トランザクションをコミット
    COMMIT;

    -- カーソルを開く
    OPEN p_cursor FOR
        SELECT ID, NAME, VALUE, CREATED_DATE
        FROM T_0069
        WHERE ID = p_id;
END SCT_0069_PROCESS_WITH_CURSOR;
/

-- 上記プロシージャを使用する別のプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0069_MAIN_PROCEDURE(
    p_id IN NUMBER
)
IS
    v_cursor SYS_REFCURSOR;
    v_id T_0069.ID%TYPE;
    v_name T_0069.NAME%TYPE;
    v_value T_0069.VALUE%TYPE;
    v_date T_0069.CREATED_DATE%TYPE;
BEGIN
    -- カーソル変数を渡すプロシージャを呼び出し
    SCT_0069_PROCESS_WITH_CURSOR(p_id, v_cursor);

    -- カーソルからデータを取得
    FETCH v_cursor INTO v_id, v_name, v_value, v_date;

    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id);
        DBMS_OUTPUT.PUT_LINE('名前: ' || v_name);
        DBMS_OUTPUT.PUT_LINE('値: ' || v_value);
        DBMS_OUTPUT.PUT_LINE('作成日: ' || TO_CHAR(v_date, 'YYYY-MM-DD'));
    ELSE
        DBMS_OUTPUT.PUT_LINE('データが見つかりませんでした。');
    END IF;

    -- カーソルを閉じる
    CLOSE v_cursor;

    -- メイン処理のコミット
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        ROLLBACK;
        RAISE;
END SCT_0069_MAIN_PROCEDURE;
/
