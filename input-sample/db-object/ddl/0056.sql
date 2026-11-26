-- テーブルの作成
CREATE TABLE T_0056 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    STATUS VARCHAR2(20),
    CREATED_DATE DATE DEFAULT SYSDATE
);

CREATE OR REPLACE PROCEDURE SCT_0056_SAVEPOINT_DEMO(
    p_success_all IN BOOLEAN DEFAULT FALSE
)
IS
    v_count NUMBER;
BEGIN
    -- 処理開始
    DBMS_OUTPUT.PUT_LINE('処理を開始します。');

    -- 最初のデータ挿入
    INSERT INTO T_0056 (ID, NAME, VALUE, STATUS)
    VALUES (4, 'アイテム4', 400, 'アクティブ');

    DBMS_OUTPUT.PUT_LINE('アイテム4を挿入しました。');

    -- 最初のセーブポイントを設定
    SAVEPOINT sp_after_first_insert;

    -- 2番目のデータ挿入
    INSERT INTO T_0056 (ID, NAME, VALUE, STATUS)
    VALUES (5, 'アイテム5', 500, 'アクティブ');

    DBMS_OUTPUT.PUT_LINE('アイテム5を挿入しました。');

    -- 2番目のセーブポイントを設定
    SAVEPOINT sp_after_second_insert;

    -- 意図的にエラーを発生させる可能性のある処理
    BEGIN
        -- 主キー違反を発生させる（IDが重複）
        INSERT INTO T_0056 (ID, NAME, VALUE, STATUS)
        VALUES (5, 'アイテム5（重複）', 550, 'アクティブ');

        DBMS_OUTPUT.PUT_LINE('アイテム5（重複）を挿入しました。');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('エラー: 主キー違反が発生しました。');

            IF p_success_all THEN
                -- 2番目のセーブポイントまでロールバック
                DBMS_OUTPUT.PUT_LINE('2番目のセーブポイントまでロールバックします。');
                ROLLBACK TO SAVEPOINT sp_after_second_insert;
            ELSE
                -- 最初のセーブポイントまでロールバック
                DBMS_OUTPUT.PUT_LINE('最初のセーブポイントまでロールバックします。');
                ROLLBACK TO SAVEPOINT sp_after_first_insert;
            END IF;
    END;

    -- 最後のデータ挿入
    INSERT INTO T_0056 (ID, NAME, VALUE, STATUS)
    VALUES (6, 'アイテム6', 600, 'アクティブ');

    DBMS_OUTPUT.PUT_LINE('アイテム6を挿入しました。');

    -- 現在のデータ数を確認
    SELECT COUNT(*) INTO v_count FROM T_0056;
    DBMS_OUTPUT.PUT_LINE('現在のデータ数: ' || v_count);

    -- コミット
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('すべての変更をコミットしました。');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('予期しないエラーが発生しました: ' || SQLERRM);
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('すべての変更をロールバックしました。');
END SCT_0056_SAVEPOINT_DEMO;
/
