CREATE OR REPLACE PROCEDURE SCT_0014_PIVOT_SAMPLE
IS
    -- 結果を格納する変数
    v_jan NUMBER;
    v_feb NUMBER;
    v_mar NUMBER;
    v_apr NUMBER;
BEGIN
    -- DUAL表を使ったPIVOT構文のサンプル
    -- まず、UNION ALLを使って複数行のデータを作成し、それをPIVOTする

    -- カーソルを使って結果を取得
    FOR r IN (
        SELECT *
        FROM (
            SELECT 'JAN' AS month, 100 AS sales FROM DUAL
            UNION ALL
            SELECT 'FEB' AS month, 150 AS sales FROM DUAL
            UNION ALL
            SELECT 'MAR' AS month, 200 AS sales FROM DUAL
            UNION ALL
            SELECT 'APR' AS month, 180 AS sales FROM DUAL
        )
        PIVOT (
            SUM(sales)
            FOR month IN (
                'JAN' AS jan,
                'FEB' AS feb,
                'MAR' AS mar,
                'APR' AS apr
            )
        )
    ) LOOP
        v_jan := r.jan;
        v_feb := r.feb;
        v_mar := r.mar;
        v_apr := r.apr;

        -- 結果を表示
        DBMS_OUTPUT.PUT_LINE('1月の売上: ' || v_jan);
        DBMS_OUTPUT.PUT_LINE('2月の売上: ' || v_feb);
        DBMS_OUTPUT.PUT_LINE('3月の売上: ' || v_mar);
        DBMS_OUTPUT.PUT_LINE('4月の売上: ' || v_apr);
        DBMS_OUTPUT.PUT_LINE('合計売上: ' || (v_jan + v_feb + v_mar + v_apr));
    END LOOP;

    -- 四半期ごとの集計を行うPIVOTの例
    DBMS_OUTPUT.PUT_LINE('---四半期ごとの集計---');
    FOR r IN (
        SELECT *
        FROM (
            SELECT
                CASE
                    WHEN month IN ('JAN', 'FEB', 'MAR') THEN 'Q1'
                    WHEN month IN ('APR', 'MAY', 'JUN') THEN 'Q2'
                    WHEN month IN ('JUL', 'AUG', 'SEP') THEN 'Q3'
                    ELSE 'Q4'
                END AS quarter,
                sales
            FROM (
                SELECT 'JAN' AS month, 100 AS sales FROM DUAL
                UNION ALL
                SELECT 'FEB' AS month, 150 AS sales FROM DUAL
                UNION ALL
                SELECT 'MAR' AS month, 200 AS sales FROM DUAL
                UNION ALL
                SELECT 'APR' AS month, 180 AS sales FROM DUAL
                UNION ALL
                SELECT 'MAY' AS month, 190 AS sales FROM DUAL
                UNION ALL
                SELECT 'JUN' AS month, 210 AS sales FROM DUAL
            )
        )
        PIVOT (
            SUM(sales)
            FOR quarter IN (
                'Q1' AS q1,
                'Q2' AS q2
            )
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('第1四半期の売上: ' || r.q1);
        DBMS_OUTPUT.PUT_LINE('第2四半期の売上: ' || r.q2);
    END LOOP;

    -- 複数の集計関数を使用したPIVOTの例
    DBMS_OUTPUT.PUT_LINE('---複数の集計関数を使用した例---');
    FOR r IN (
        SELECT *
        FROM (
            SELECT 'JAN' AS month, 100 AS sales, 5 AS orders FROM DUAL
            UNION ALL
            SELECT 'FEB' AS month, 150 AS sales, 7 AS orders FROM DUAL
            UNION ALL
            SELECT 'MAR' AS month, 200 AS sales, 10 AS orders FROM DUAL
        )
        PIVOT (
            SUM(sales) AS sum_sales,
            AVG(orders) AS avg_orders
            FOR month IN (
                'JAN' AS jan,
                'FEB' AS feb,
                'MAR' AS mar
            )
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('1月の売上合計: ' || r.jan_sum_sales || ', 平均注文数: ' || r.jan_avg_orders);
        DBMS_OUTPUT.PUT_LINE('2月の売上合計: ' || r.feb_sum_sales || ', 平均注文数: ' || r.feb_avg_orders);
        DBMS_OUTPUT.PUT_LINE('3月の売上合計: ' || r.mar_sum_sales || ', 平均注文数: ' || r.mar_avg_orders);
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0014_PIVOT_SAMPLE;
/
