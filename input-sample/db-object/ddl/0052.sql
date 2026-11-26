-- テーブルの作成
CREATE TABLE T_0052 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    STATUS VARCHAR2(20),
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- SQLCODE変数を参照するプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0052_CHECK_SQLCODE_SAMPLE(
    p_id IN NUMBER,
    p_new_value IN NUMBER
)
IS
    v_name VARCHAR2(100);
    v_current_value NUMBER;
    v_status VARCHAR2(20);
    v_error_code NUMBER;
    v_error_msg VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.PUT_LINE('処理を開始します。ID: ' || p_id);

    -- 最初のSQLを実行
    BEGIN
        SELECT NAME, VALUE, STATUS
        INTO v_name, v_current_value, v_status
        FROM T_0052
        WHERE ID = p_id;

        -- EXCEPTION句の外でSQLCODEを参照
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;

        DBMS_OUTPUT.PUT_LINE('最初のSQLの実行後のSQLCODE: ' || v_error_code);
        DBMS_OUTPUT.PUT_LINE('最初のSQLの実行後のSQLERRM: ' || v_error_msg);

        -- 取得したデータを表示
        DBMS_OUTPUT.PUT_LINE('取得したデータ:');
        DBMS_OUTPUT.PUT_LINE('  名前: ' || v_name);
        DBMS_OUTPUT.PUT_LINE('  現在の値: ' || v_current_value);
        DBMS_OUTPUT.PUT_LINE('  ステータス: ' || v_status);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_error_code := SQLCODE;
            v_error_msg := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('データが見つかりません。SQLCODE: ' || v_error_code);
            DBMS_OUTPUT.PUT_LINE('エラーメッセージ: ' || v_error_msg);
            RETURN;
    END;

    -- ステータスチェック
    IF v_status = '非アクティブ' THEN
        DBMS_OUTPUT.PUT_LINE('非アクティブのレコードは更新できません。');
        RETURN;
    END IF;

    -- 更新処理
    BEGIN
        UPDATE T_0052
        SET VALUE = p_new_value,
            CREATED_DATE = SYSDATE
        WHERE ID = p_id;

        -- EXCEPTION句の外でSQLCODEを参照
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;

        DBMS_OUTPUT.PUT_LINE('更新処理後のSQLCODE: ' || v_error_code);
        DBMS_OUTPUT.PUT_LINE('更新処理後のSQLERRM: ' || v_error_msg);

        -- 更新された行数を確認
        IF SQL%ROWCOUNT > 0 THEN
            DBMS_OUTPUT.PUT_LINE('更新が成功しました。新しい値: ' || p_new_value);
        ELSE
            DBMS_OUTPUT.PUT_LINE('更新対象のレコードがありませんでした。');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;
            v_error_msg := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('更新中にエラーが発生しました。SQLCODE: ' || v_error_code);
            DBMS_OUTPUT.PUT_LINE('エラーメッセージ: ' || v_error_msg);
            ROLLBACK;
            RETURN;
    END;

    -- 存在しないテーブルにアクセスして意図的にエラーを発生させる
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM NON_EXISTENT_TABLE';
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;
            v_error_msg := SQLERRM;
            DBMS_OUTPUT.PUT_LINE('存在しないテーブルへのアクセスでエラーが発生しました。');
            DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || v_error_code);
            DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || v_error_msg);
    END;

    -- 最終的なSQLCODEの状態を確認
    v_error_code := SQLCODE;
    v_error_msg := SQLERRM;
    DBMS_OUTPUT.PUT_LINE('プロシージャ終了時のSQLCODE: ' || v_error_code);
    DBMS_OUTPUT.PUT_LINE('プロシージャ終了時のSQLERRM: ' || v_error_msg);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('処理が完了しました。');

EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('予期しないエラーが発生しました。SQLCODE: ' || v_error_code);
        DBMS_OUTPUT.PUT_LINE('エラーメッセージ: ' || v_error_msg);
        ROLLBACK;
END SCT_0052_CHECK_SQLCODE_SAMPLE;
/
