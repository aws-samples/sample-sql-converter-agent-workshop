-- テーブルの作成
CREATE TABLE T_0057_STRINGS (
    ID NUMBER PRIMARY KEY,
    INPUT_STRING VARCHAR2(200),
    PROCESSED_STRING VARCHAR2(200)
);

CREATE OR REPLACE PROCEDURE SCT_0057_STRING_OPERATIONS
IS
    -- カーソルの定義
    CURSOR c_strings IS
        SELECT ID, INPUT_STRING
        FROM T_0057_STRINGS;

    v_processed VARCHAR2(200);
BEGIN
    -- 各文字列を処理
    FOR rec IN c_strings LOOP
        v_processed := rec.INPUT_STRING;

        -- 1. 電話番号のフォーマットを変更 (03-1234-5678 → 03(1234)5678)
        v_processed := REGEXP_REPLACE(v_processed, '(\d{2,4})-(\d{2,4})-(\d{4})', '\1(\2)\3');

        -- 2. 日付のフォーマットを変更 (2023/07/15 → 2023-07-15)
        v_processed := REGEXP_REPLACE(v_processed, '(\d{4})/(\d{2})/(\d{2})', '\1-\2-\3');

        -- 3. URLの前に「リンク:」を追加
        v_processed := REGEXP_REPLACE(v_processed, '(https?://[^\s,、]+)', 'リンク: \1');

        -- 4. 金額表記を統一 (12,345円 → ￥12,345)
        v_processed := REGEXP_REPLACE(v_processed, '(\d{1,3}(,\d{3})*)(円)', '￥\1');

        -- 5. 年月日表記を西暦表記に変更 (2023年7月4日 → 2023-07-04)
        v_processed := REGEXP_REPLACE(v_processed, '(\d{4})年(\d{1,2})月(\d{1,2})日', '\1-' ||
                                     LPAD(REGEXP_SUBSTR(v_processed, '(\d{4})年(\d{1,2})月', 1, 1, NULL, 2), 2, '0') || '-' ||
                                     LPAD(REGEXP_SUBSTR(v_processed, '月(\d{1,2})日', 1, 1, NULL, 1), 2, '0'));

        -- 処理結果を更新
        UPDATE T_0057_STRINGS
        SET PROCESSED_STRING = v_processed
        WHERE ID = rec.ID;

        -- 結果を出力
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.ID);
        DBMS_OUTPUT.PUT_LINE('  入力: ' || rec.INPUT_STRING);
        DBMS_OUTPUT.PUT_LINE('  出力: ' || v_processed);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('文字列処理が完了しました。');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END SCT_0057_STRING_OPERATIONS;
/

CREATE OR REPLACE PROCEDURE SCT_0057_EXTRACT_PATTERNS
IS
    -- カーソルの定義
    CURSOR c_strings IS
        SELECT ID, INPUT_STRING
        FROM T_0057_STRINGS;

    -- 抽出したパターンを格納する変数
    v_phone VARCHAR2(20);
    v_email VARCHAR2(100);
    v_date VARCHAR2(20);
    v_code VARCHAR2(20);
    v_price VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== パターン抽出結果 =====');

    -- 各文字列からパターンを抽出
    FOR rec IN c_strings LOOP
        -- 電話番号を抽出
        v_phone := REGEXP_SUBSTR(rec.INPUT_STRING, '\d{2,4}-\d{2,4}-\d{4}');

        -- メールアドレスを抽出
        v_email := REGEXP_SUBSTR(rec.INPUT_STRING, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');

        -- 日付を抽出 (YYYY/MM/DD形式)
        v_date := REGEXP_SUBSTR(rec.INPUT_STRING, '\d{4}/\d{2}/\d{2}');
        IF v_date IS NULL THEN
            -- 年月日形式も試す
            v_date := REGEXP_SUBSTR(rec.INPUT_STRING, '\d{4}年\d{1,2}月\d{1,2}日');
        END IF;

        -- 商品コードを抽出 (XXX-XXX-XXX形式)
        v_code := REGEXP_SUBSTR(rec.INPUT_STRING, '[A-Z]+-\d+-[A-Z]+');

        -- 価格を抽出
        v_price := REGEXP_SUBSTR(rec.INPUT_STRING, '\d{1,3}(,\d{3})*円');

        -- 結果を出力
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.ID || ' の抽出結果:');
        DBMS_OUTPUT.PUT_LINE('  入力文字列: ' || rec.INPUT_STRING);

        IF v_phone IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  電話番号: ' || v_phone);
        END IF;

        IF v_email IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  メールアドレス: ' || v_email);
        END IF;

        IF v_date IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  日付: ' || v_date);
        END IF;

        IF v_code IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  商品コード: ' || v_code);
        END IF;

        IF v_price IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  価格: ' || v_price);
        END IF;

        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('パターン抽出が完了しました。');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0057_EXTRACT_PATTERNS;
/
