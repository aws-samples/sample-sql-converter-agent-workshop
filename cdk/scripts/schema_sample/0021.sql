-- テーブル1の作成
CREATE TABLE T_0021_DEPARTMENTS (
    DEPT_ID NUMBER PRIMARY KEY,
    DEPT_NAME VARCHAR2(100)
);

-- テーブル2の作成
CREATE TABLE T_0021_EMPLOYEES (
    EMP_ID NUMBER PRIMARY KEY,
    EMP_NAME VARCHAR2(100),
    SALARY NUMBER(10,2)
);

-- クロスジョインを使用したプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0021_CROSS_JOIN
IS
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('部門と従業員のクロスジョイン結果:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('部門ID | 部門名 | 従業員ID | 従業員名 | 給与');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- クロスジョインを実行
    FOR rec IN (
        SELECT
            d.DEPT_ID,
            d.DEPT_NAME,
            e.EMP_ID,
            e.EMP_NAME,
            e.SALARY
        FROM
            T_0021_DEPARTMENTS d
            CROSS JOIN T_0021_EMPLOYEES e
        ORDER BY
            d.DEPT_ID, e.EMP_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            LPAD(rec.DEPT_ID, 6) || ' | ' ||
            RPAD(rec.DEPT_NAME, 8) || ' | ' ||
            LPAD(rec.EMP_ID, 8) || ' | ' ||
            RPAD(rec.EMP_NAME, 8) || ' | ' ||
            LPAD(TO_CHAR(rec.SALARY, '9,999.99'), 8)
        );
        v_count := v_count + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('合計: ' || v_count || ' 行');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0021_CROSS_JOIN;
/
