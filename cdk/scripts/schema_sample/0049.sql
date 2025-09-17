CREATE OR REPLACE PROCEDURE SCT_0049_timestamp(
    p_date IN DATE,
    p_days_to_add IN NUMBER
)
IS
    v_result_date DATE;
    v_timestamp TIMESTAMP;
    v_timestamp_tz TIMESTAMP WITH TIME ZONE;
    v_interval INTERVAL DAY TO SECOND;
    v_next_day DATE;
    v_months_between NUMBER;
    v_add_months DATE;
BEGIN
    -- Oracle特有の日付処理
    v_result_date := p_date + p_days_to_add;  -- 日付への数値加算（PostgreSQLでは異なる構文）

    -- NEXT_DAY関数（PostgreSQLに直接対応する関数がない）
    v_next_day := NEXT_DAY(p_date, 'MONDAY');

    -- Oracle特有のTRUNC関数の使用方法
    v_result_date := TRUNC(p_date, 'MM');  -- 月の初日に切り捨て

    -- Oracle特有のLAST_DAY関数
    v_result_date := LAST_DAY(p_date);  -- 月の最終日

    -- MONTHS_BETWEEN関数（実装が異なる）
    v_months_between := MONTHS_BETWEEN(SYSDATE, p_date);

    -- ADD_MONTHS関数
    v_add_months := ADD_MONTHS(p_date, 3);

    -- Oracle特有のタイムスタンプ処理
    v_timestamp := SYSTIMESTAMP;
    v_timestamp_tz := CURRENT_TIMESTAMP;

    -- Oracle特有のタイムゾーン変換
    v_timestamp_tz := v_timestamp AT TIME ZONE 'America/New_York';

    -- Oracle特有のINTERVAL型の使用
    v_interval := NUMTODSINTERVAL(p_days_to_add, 'DAY');
    v_result_date := p_date + v_interval;

    -- Oracle特有の日付フォーマット
    DBMS_OUTPUT.PUT_LINE('日付: ' || TO_CHAR(p_date, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('結果日付: ' || TO_CHAR(v_result_date, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('次の月曜日: ' || TO_CHAR(v_next_day, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('月の初日: ' || TO_CHAR(TRUNC(p_date, 'MM'), 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('月の最終日: ' || TO_CHAR(LAST_DAY(p_date), 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('月数の差: ' || v_months_between);
    DBMS_OUTPUT.PUT_LINE('3ヶ月後: ' || TO_CHAR(v_add_months, 'DD-MON-YYYY'));

    -- Oracle特有のタイムスタンプフォーマット
    DBMS_OUTPUT.PUT_LINE('現在のタイムスタンプ: ' ||
        TO_CHAR(v_timestamp, 'DD-MON-YYYY HH24:MI:SS.FF3 TZR'));
    DBMS_OUTPUT.PUT_LINE('ニューヨーク時間: ' ||
        TO_CHAR(v_timestamp_tz, 'DD-MON-YYYY HH24:MI:SS.FF3 TZR'));

    -- Oracle特有の日付抽出
    DBMS_OUTPUT.PUT_LINE('年: ' || EXTRACT(YEAR FROM p_date));
    DBMS_OUTPUT.PUT_LINE('月: ' || TO_CHAR(p_date, 'MM'));
    DBMS_OUTPUT.PUT_LINE('日: ' || TO_CHAR(p_date, 'DD'));

    -- Oracle特有の日付計算
    DBMS_OUTPUT.PUT_LINE('日付差: ' || (SYSDATE - p_date));

    -- Oracle特有のTIMESTAMP WITH LOCAL TIME ZONE型
    DBMS_OUTPUT.PUT_LINE('ローカルタイムゾーン: ' ||
        TO_CHAR(LOCALTIMESTAMP, 'DD-MON-YYYY HH24:MI:SS.FF3'));

    -- Oracle特有のSYSDATE関数の使用
    IF p_date > SYSDATE THEN
        DBMS_OUTPUT.PUT_LINE('未来の日付です');
    ELSE
        DBMS_OUTPUT.PUT_LINE('過去または現在の日付です');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
