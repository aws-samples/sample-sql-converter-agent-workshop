-- テーブル作成
CREATE TABLE T_0070 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    CREATED_BY VARCHAR2(30),
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- アプリケーションコンテキストの作成
CREATE OR REPLACE CONTEXT SCT_0070_user_ctx USING SCT_0070_user_ctx_pkg;

-- コンテキストを設定するためのパッケージ仕様
CREATE OR REPLACE PACKAGE SCT_0070_user_ctx_pkg IS
    PROCEDURE set_user_id(p_user_id IN VARCHAR2);
END SCT_0070_user_ctx_pkg;
/

-- コンテキストを設定するためのパッケージ本体
CREATE OR REPLACE PACKAGE BODY SCT_0070_user_ctx_pkg IS
    PROCEDURE set_user_id(p_user_id IN VARCHAR2) IS
    BEGIN
        DBMS_SESSION.SET_CONTEXT('SCT_0070_user_ctx', 'user_id', p_user_id);
    END set_user_id;
END SCT_0070_user_ctx_pkg;
/

-- 自律型トランザクションとアプリケーションコンテキストを使用するプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0070_INSERT_WITH_CONTEXT(
    p_id IN NUMBER,
    p_name IN VARCHAR2,
    p_value IN NUMBER
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_user VARCHAR2(30);
BEGIN
    -- アプリケーションコンテキストから現在のユーザーIDを取得
    v_user := SYS_CONTEXT('SCT_0070_user_ctx', 'user_id');

    -- ユーザーIDが設定されていない場合はデフォルト値を使用
    IF v_user IS NULL THEN
        v_user := 'UNKNOWN';
    END IF;

    -- テーブルにデータを挿入
    INSERT INTO T_0070 (ID, NAME, VALUE, CREATED_BY, CREATED_DATE)
    VALUES (p_id, p_name, p_value, v_user, SYSDATE);

    -- 自律型トランザクション内でコミット
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('レコードが挿入されました。ID: ' || p_id || ', 作成者: ' || v_user);
EXCEPTION
    WHEN OTHERS THEN
        -- エラー発生時はロールバック
        ROLLBACK;
        RAISE;
END SCT_0070_INSERT_WITH_CONTEXT;
/

-- アプリケーションコンテキストを使用する別のプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0070_UPDATE_WITH_CONTEXT(
    p_id IN NUMBER,
    p_new_value IN NUMBER
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_user VARCHAR2(30);
    v_log_message VARCHAR2(200);
BEGIN
    -- アプリケーションコンテキストから現在のユーザーIDを取得
    v_user := SYS_CONTEXT('SCT_0070_user_ctx', 'user_id');

    -- ユーザーIDが設定されていない場合はデフォルト値を使用
    IF v_user IS NULL THEN
        v_user := 'UNKNOWN';
    END IF;

    -- ログメッセージを作成
    v_log_message := 'ユーザー ' || v_user || ' がID=' || p_id || ' のレコードを更新しました。新しい値: ' || p_new_value;

    -- テーブルを更新
    UPDATE T_0070
    SET VALUE = p_new_value
    WHERE ID = p_id;

    -- 自律型トランザクション内でコミット
    COMMIT;

    DBMS_OUTPUT.PUT_LINE(v_log_message);
EXCEPTION
    WHEN OTHERS THEN
        -- エラー発生時はロールバック
        ROLLBACK;
        RAISE;
END SCT_0070_UPDATE_WITH_CONTEXT;
/
