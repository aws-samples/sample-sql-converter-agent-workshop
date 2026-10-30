CREATE OR REPLACE PROCEDURE SCT_0045_oracle_date_timestamp_demo (
    p_date_string IN VARCHAR2,
    p_timestamp_string IN VARCHAR2
) AS
    -- 変数宣言
    v_date DATE;
    v_timestamp TIMESTAMP;
    v_formatted_date VARCHAR2(100);
    v_formatted_timestamp VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Oracle 日付・タイムスタンプ変換デモ');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- TO_DATE を使用した日付変換（PostgreSQLと互換性がない書式）
    -- Oracle固有の書式要素: RR（2桁年）、SYYYY（符号付き年）、J（ユリウス日）、TS（短い時間）
    BEGIN
        -- RR書式（PostgreSQLにはない）を使用
        v_date := TO_DATE(p_date_string, 'DD-MON-RR HH24:MI:SS');
        DBMS_OUTPUT.PUT_LINE('入力文字列: ' || p_date_string);
        DBMS_OUTPUT.PUT_LINE('TO_DATE変換結果: ' || v_date);

        -- 別の書式で表示
        v_formatted_date := TO_CHAR(v_date, 'SYYYY-MM-DD HH24:MI:SS');
        DBMS_OUTPUT.PUT_LINE('フォーマット済み日付: ' || v_formatted_date);

        -- ユリウス日に変換（PostgreSQLにはない）
        v_formatted_date := TO_CHAR(v_date, 'J');
        DBMS_OUTPUT.PUT_LINE('ユリウス日: ' || v_formatted_date);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('日付変換エラー: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- TO_TIMESTAMP を使用したタイムスタンプ変換（PostgreSQLと互換性がない書式）
    -- Oracle固有の書式要素: FF（小数秒）、TZR（タイムゾーン地域）、TZD（タイムゾーン略称）
    BEGIN
        -- FF9書式（PostgreSQLでは異なる動作）を使用
        v_timestamp := TO_TIMESTAMP(p_timestamp_string, 'DD-MON-YYYY HH24:MI:SS.FF9 TZR TZD');
        DBMS_OUTPUT.PUT_LINE('入力文字列: ' || p_timestamp_string);
        DBMS_OUTPUT.PUT_LINE('TO_TIMESTAMP変換結果: ' || v_timestamp);

        -- 別の書式で表示（Oracle固有の書式要素を使用）
        v_formatted_timestamp := TO_CHAR(v_timestamp, 'YYYY-MM-DD HH24:MI:SS.FF9 TZH:TZM TZR');
        DBMS_OUTPUT.PUT_LINE('フォーマット済みタイムスタンプ: ' || v_formatted_timestamp);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('タイムスタンプ変換エラー: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- 追加の日付計算（Oracle固有の機能）
    BEGIN
        -- 日付から日付への減算（PostgreSQLでは異なる結果）
        DBMS_OUTPUT.PUT_LINE('現在日付から7日前: ' || TO_CHAR(SYSDATE - 7, 'DD-MON-YYYY'));

        -- 月の加算（ADD_MONTHS関数）
        DBMS_OUTPUT.PUT_LINE('現在日付から3ヶ月後: ' || TO_CHAR(ADD_MONTHS(SYSDATE, 3), 'DD-MON-YYYY'));

        -- 次の指定曜日（NEXT_DAY関数）- Oracle固有の曜日指定
        DBMS_OUTPUT.PUT_LINE('次の金曜日: ' || TO_CHAR(NEXT_DAY(SYSDATE, 'FRIDAY'), 'DD-MON-YYYY'));

        -- 月の最終日（LAST_DAY関数）
        DBMS_OUTPUT.PUT_LINE('今月の最終日: ' || TO_CHAR(LAST_DAY(SYSDATE), 'DD-MON-YYYY'));
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('日付計算エラー: ' || SQLERRM);
    END;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('プロシージャ実行エラー: ' || SQLERRM);
END;
/
