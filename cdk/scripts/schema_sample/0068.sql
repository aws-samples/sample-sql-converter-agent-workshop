-- テーブルの作成
CREATE TABLE T_0068_USERS (
    USER_ID NUMBER PRIMARY KEY,
    USERNAME VARCHAR2(50) UNIQUE,
    EMAIL VARCHAR2(100) UNIQUE,
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- エラーログテーブルの作成
CREATE TABLE T_0068_ERROR_LOG (
    LOG_ID NUMBER PRIMARY KEY,
    ERROR_CODE NUMBER,
    ERROR_MESSAGE VARCHAR2(4000),
    PROCEDURE_NAME VARCHAR2(100),
    LOG_DATE DATE DEFAULT SYSDATE
);

-- シーケンスの作成
CREATE SEQUENCE T_0068_LOG_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE OR REPLACE PROCEDURE SCT_0068_INSERT_USER(
    p_user_id IN NUMBER,
    p_username IN VARCHAR2,
    p_email IN VARCHAR2
)
IS
    v_error_code NUMBER;
    v_error_msg VARCHAR2(4000);
BEGIN
    -- ユーザーの挿入を試みる
    INSERT INTO T_0068_USERS (USER_ID, USERNAME, EMAIL)
    VALUES (p_user_id, p_username, p_email);

    DBMS_OUTPUT.PUT_LINE('ユーザーを正常に追加しました。ID: ' || p_user_id);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- SQLCODEを数値型として取得
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;

        -- エラーコードに基づいて処理
        CASE v_error_code
            WHEN -1 THEN
                DBMS_OUTPUT.PUT_LINE('一意制約違反が発生しました。エラーコード: ' || v_error_code);

                -- ユーザー名とメールアドレスのどちらが重複しているかを確認
                BEGIN
                    SELECT 1 INTO v_error_code FROM T_0068_USERS WHERE USERNAME = p_username;
                    DBMS_OUTPUT.PUT_LINE('ユーザー名 "' || p_username || '" は既に使用されています。');
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        DBMS_OUTPUT.PUT_LINE('メールアドレス "' || p_email || '" は既に使用されています。');
                END;

            WHEN -2291 THEN
                DBMS_OUTPUT.PUT_LINE('親キーが存在しません。エラーコード: ' || v_error_code);

            WHEN -12899 THEN
                DBMS_OUTPUT.PUT_LINE('値が列の長さを超えています。エラーコード: ' || v_error_code);

            ELSE
                DBMS_OUTPUT.PUT_LINE('予期しないエラーが発生しました。エラーコード: ' || v_error_code);
        END CASE;

        -- エラーログに記録
        INSERT INTO T_0068_ERROR_LOG (LOG_ID, ERROR_CODE, ERROR_MESSAGE, PROCEDURE_NAME)
        VALUES (T_0068_LOG_SEQ.NEXTVAL, v_error_code, v_error_msg, 'SCT_0068_INSERT_USER');

        COMMIT;
END SCT_0068_INSERT_USER;
/

CREATE OR REPLACE PROCEDURE SCT_0068_TEST_ERROR_CODES
IS
    v_user_id NUMBER;
    v_result NUMBER;
    v_error_code NUMBER;
    v_error_msg VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== SQLCODEの数値比較テスト =====');

    -- テスト1: 存在しないユーザーIDを検索
    BEGIN
        SELECT USER_ID INTO v_user_id
        FROM T_0068_USERS
        WHERE USER_ID = 999;

        DBMS_OUTPUT.PUT_LINE('ユーザーID 999 が見つかりました。');
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;

            -- SQLCODEを数値として比較
            IF v_error_code = -1403 THEN  -- NO_DATA_FOUND
                DBMS_OUTPUT.PUT_LINE('データが見つかりません。エラーコード: ' || v_error_code);
            ELSE
                DBMS_OUTPUT.PUT_LINE('その他のエラー。エラーコード: ' || v_error_code);
            END IF;
    END;

    -- テスト2: 存在しないテーブルにアクセス
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM non_existent_table';
        DBMS_OUTPUT.PUT_LINE('テーブルが存在します。');
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;

            -- SQLCODEを数値として比較
            IF v_error_code = -942 THEN
                DBMS_OUTPUT.PUT_LINE('テーブルが存在しません。エラーコード: ' || v_error_code);
            ELSIF v_error_code < -1000 THEN
                DBMS_OUTPUT.PUT_LINE('深刻なエラーが発生しました。エラーコード: ' || v_error_code);
            ELSE
                DBMS_OUTPUT.PUT_LINE('その他のエラー。エラーコード: ' || v_error_code);
            END IF;
    END;

    -- テスト3: 算術演算エラー
    BEGIN
        v_result := 100 / 0;
        DBMS_OUTPUT.PUT_LINE('計算結果: ' || v_result);
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := SQLCODE;

            -- SQLCODEを数値として比較
            IF v_error_code = -1476 THEN  -- ORA-01476: 除数にゼロが指定されました
                DBMS_OUTPUT.PUT_LINE('ゼロ除算エラー。エラーコード: ' || v_error_code);
            ELSE
                DBMS_OUTPUT.PUT_LINE('その他のエラー。エラーコード: ' || v_error_code);
            END IF;
    END;

    -- エラーコードの範囲チェック
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===== エラーコードの範囲チェック =====');

    FOR i IN 1..3 LOOP
        BEGIN
            CASE i
                WHEN 1 THEN
                    -- 存在しないテーブル
                    EXECUTE IMMEDIATE 'SELECT * FROM no_such_table';
                WHEN 2 THEN
                    -- ゼロ除算
                    v_result := 1/0;
                WHEN 3 THEN
                    -- 構文エラー
                    EXECUTE IMMEDIATE 'SELECT * FORM dual';
            END CASE;
        EXCEPTION
            WHEN OTHERS THEN
                v_error_code := SQLCODE;
                v_error_msg := SQLERRM;

                -- エラーコードの範囲をチェック
                IF v_error_code BETWEEN -1000 AND -900 THEN
                    DBMS_OUTPUT.PUT_LINE('一般的なエラー: ' || v_error_code || ' - ' || v_error_msg);
                ELSIF v_error_code < -1000 THEN
                    DBMS_OUTPUT.PUT_LINE('特定のエラー: ' || v_error_code || ' - ' || v_error_msg);
                ELSIF v_error_code = 0 THEN
                    DBMS_OUTPUT.PUT_LINE('成功: ' || v_error_code || ' - ' || v_error_msg);
                ELSIF v_error_code > 0 THEN
                    DBMS_OUTPUT.PUT_LINE('警告: ' || v_error_code || ' - ' || v_error_msg);
                END IF;

                -- エラーログに記録
                INSERT INTO T_0068_ERROR_LOG (LOG_ID, ERROR_CODE, ERROR_MESSAGE, PROCEDURE_NAME)
                VALUES (T_0068_LOG_SEQ.NEXTVAL, v_error_code, v_error_msg, 'SCT_0068_TEST_ERROR_CODES');
        END;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('すべてのテストが完了しました。');

EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('予期しないエラーが発生しました。エラーコード: ' || v_error_code || ', メッセージ: ' || v_error_msg);

        -- エラーログに記録
        INSERT INTO T_0068_ERROR_LOG (LOG_ID, ERROR_CODE, ERROR_MESSAGE, PROCEDURE_NAME)
        VALUES (T_0068_LOG_SEQ.NEXTVAL, v_error_code, v_error_msg, 'SCT_0068_TEST_ERROR_CODES');
        COMMIT;
END SCT_0068_TEST_ERROR_CODES;
/
