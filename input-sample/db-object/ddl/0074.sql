-- テーブルの作成
CREATE TABLE T_0074 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    KANA VARCHAR2(100)
);

-- 言語依存のソート処理を使用したプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0074_JAPANESE_SORT(
    p_sort_field IN VARCHAR2 DEFAULT 'KANA',
    p_sort_order IN VARCHAR2 DEFAULT 'ASC'
)
IS
    -- カーソル変数の宣言
    TYPE t_cursor IS REF CURSOR;
    v_cursor t_cursor;

    -- レコード変数の宣言
    v_id T_0074.ID%TYPE;
    v_name T_0074.NAME%TYPE;
    v_kana T_0074.KANA%TYPE;

    -- 動的SQL用の変数
    v_sql VARCHAR2(1000);
BEGIN
    -- セッションの言語ソートを日本語に設定
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = JAPANESE';
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_COMP = LINGUISTIC';

    DBMS_OUTPUT.PUT_LINE('日本語ソートを使用した結果:');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');

    -- 動的SQLの構築
    v_sql := 'SELECT ID, NAME, KANA FROM T_0074 ORDER BY ' || p_sort_field || ' ' || p_sort_order;

    -- カーソルを開く
    OPEN v_cursor FOR v_sql;

    -- 結果を取得して表示
    LOOP
        FETCH v_cursor INTO v_id, v_name, v_kana;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', 名前: ' || v_name || ', カナ: ' || v_kana);
    END LOOP;

    -- カーソルを閉じる
    CLOSE v_cursor;

    -- 比較のため、バイナリソートに戻す
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = BINARY';
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_COMP = BINARY';

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('バイナリソートを使用した結果:');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');

    -- 同じクエリを実行（今度はバイナリソート）
    OPEN v_cursor FOR v_sql;

    -- 結果を取得して表示
    LOOP
        FETCH v_cursor INTO v_id, v_name, v_kana;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', 名前: ' || v_name || ', カナ: ' || v_kana);
    END LOOP;

    -- カーソルを閉じる
    CLOSE v_cursor;

EXCEPTION
    WHEN OTHERS THEN
        -- エラー処理
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        -- セッション設定を元に戻す
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = BINARY';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_COMP = BINARY';
        RAISE;
END SCT_0074_JAPANESE_SORT;
/

-- COLLATE句を使用した言語依存のソート処理を行うプロシージャ（静的SQL版）
CREATE OR REPLACE PROCEDURE SCT_0074_COLLATE_SORT
IS
    -- カーソルの宣言（静的SQL）
    CURSOR c_japanese_sort IS
        SELECT ID, NAME, KANA
        FROM T_0074
        ORDER BY KANA COLLATE JAPANESE ASC;

    CURSOR c_default_sort IS
        SELECT ID, NAME, KANA
        FROM T_0074
        ORDER BY KANA ASC;

    -- レコード変数の宣言
    v_record c_japanese_sort%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('日本語照合順序（COLLATE JAPANESE）を使用した結果:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');

    -- 日本語照合順序でソートしたデータを取得
    OPEN c_japanese_sort;
    LOOP
        FETCH c_japanese_sort INTO v_record;
        EXIT WHEN c_japanese_sort%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_record.ID || ', 名前: ' || v_record.NAME || ', カナ: ' || v_record.KANA);
    END LOOP;
    CLOSE c_japanese_sort;

    -- 比較のため、デフォルトの照合順序を使用
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('デフォルト照合順序を使用した結果:');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');

    -- デフォルト照合順序でソートしたデータを取得
    OPEN c_default_sort;
    LOOP
        FETCH c_default_sort INTO v_record;
        EXIT WHEN c_default_sort%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_record.ID || ', 名前: ' || v_record.NAME || ', カナ: ' || v_record.KANA);
    END LOOP;
    CLOSE c_default_sort;

EXCEPTION
    WHEN OTHERS THEN
        -- エラー処理
        IF c_japanese_sort%ISOPEN THEN
            CLOSE c_japanese_sort;
        END IF;
        IF c_default_sort%ISOPEN THEN
            CLOSE c_default_sort;
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0074_COLLATE_SORT;
/

-- NLSSORTを使用した言語依存のソート処理を行うプロシージャ（静的SQL版）
CREATE OR REPLACE PROCEDURE SCT_0074_NLSSORT_JAPANESE
IS
    -- カーソルの宣言（静的SQL）
    CURSOR c_japanese_sort IS
        SELECT ID, NAME, KANA
        FROM T_0074
        ORDER BY NLSSORT(KANA, 'NLS_SORT=JAPANESE');

    CURSOR c_default_sort IS
        SELECT ID, NAME, KANA
        FROM T_0074
        ORDER BY KANA;

    -- レコード変数の宣言
    v_record c_japanese_sort%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('日本語ソート（NLSSORT）を使用した結果:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------');

    -- 日本語ソートでデータを取得
    OPEN c_japanese_sort;
    LOOP
        FETCH c_japanese_sort INTO v_record;
        EXIT WHEN c_japanese_sort%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_record.ID || ', 名前: ' || v_record.NAME || ', カナ: ' || v_record.KANA);
    END LOOP;
    CLOSE c_japanese_sort;

    -- 比較のため、デフォルトのソートを使用
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('デフォルトソートを使用した結果:');
    DBMS_OUTPUT.PUT_LINE('---------------------------');

    -- デフォルトソートでデータを取得
    OPEN c_default_sort;
    LOOP
        FETCH c_default_sort INTO v_record;
        EXIT WHEN c_default_sort%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_record.ID || ', 名前: ' || v_record.NAME || ', カナ: ' || v_record.KANA);
    END LOOP;
    CLOSE c_default_sort;

EXCEPTION
    WHEN OTHERS THEN
        -- エラー処理
        IF c_japanese_sort%ISOPEN THEN
            CLOSE c_japanese_sort;
        END IF;
        IF c_default_sort%ISOPEN THEN
            CLOSE c_default_sort;
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0074_NLSSORT_JAPANESE;
/
