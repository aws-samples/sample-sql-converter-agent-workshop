-- 従業員テーブル
CREATE TABLE T_0047_EMPLOYEES (
    EMPLOYEE_ID NUMBER PRIMARY KEY,
    EMPLOYEE_NAME VARCHAR2(100),
    DEPARTMENT_ID NUMBER,
    SALARY NUMBER(10,2),
    HIRE_DATE DATE
);

-- 部門テーブル
CREATE TABLE T_0047_DEPARTMENTS (
    DEPARTMENT_ID NUMBER PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR2(100),
    LOCATION_ID NUMBER
);

-- 場所テーブル
CREATE TABLE T_0047_LOCATIONS (
    LOCATION_ID NUMBER PRIMARY KEY,
    LOCATION_NAME VARCHAR2(100),
    COUNTRY VARCHAR2(50)
);

-- プロジェクトテーブル
CREATE TABLE T_0047_PROJECTS (
    PROJECT_ID NUMBER PRIMARY KEY,
    PROJECT_NAME VARCHAR2(100),
    DEPARTMENT_ID NUMBER,
    START_DATE DATE,
    END_DATE DATE
);

CREATE OR REPLACE PROCEDURE SCT_0047_COMPLEX_OUTER_JOIN_REPORT(
    p_min_salary IN NUMBER DEFAULT 0
)
IS
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== 複雑な外部結合を使用したレポート =====');

    -- 例1: (+)演算子を使用した古い形式の外部結合
    DBMS_OUTPUT.PUT_LINE('1. 部門に所属していない従業員も含めた一覧:');
    FOR rec IN (
        SELECT e.EMPLOYEE_ID, e.EMPLOYEE_NAME, e.SALARY,
               d.DEPARTMENT_NAME,
               l.LOCATION_NAME
        FROM T_0047_EMPLOYEES e, T_0047_DEPARTMENTS d, T_0047_LOCATIONS l
        WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID(+)
          AND d.LOCATION_ID = l.LOCATION_ID(+)
          AND e.SALARY >= p_min_salary
        ORDER BY e.EMPLOYEE_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.EMPLOYEE_ID ||
                           ', 名前: ' || rec.EMPLOYEE_NAME ||
                           ', 給与: ' || rec.SALARY ||
                           ', 部門: ' || NVL(rec.DEPARTMENT_NAME, '未所属') ||
                           ', 場所: ' || NVL(rec.LOCATION_NAME, '不明'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    -- 例2: 複数の条件を持つ外部結合
    DBMS_OUTPUT.PUT_LINE('2. 複数の条件を持つ外部結合:');
    FOR rec IN (
        SELECT e.EMPLOYEE_ID, e.EMPLOYEE_NAME,
               d.DEPARTMENT_NAME, l.LOCATION_NAME
        FROM T_0047_EMPLOYEES e, T_0047_DEPARTMENTS d, T_0047_LOCATIONS l
        WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID(+)
          AND d.LOCATION_ID = l.LOCATION_ID(+)
          AND (d.DEPARTMENT_ID = 10 OR d.DEPARTMENT_ID = 20 OR d.DEPARTMENT_ID IS NULL)
        ORDER BY e.EMPLOYEE_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.EMPLOYEE_ID ||
                           ', 名前: ' || rec.EMPLOYEE_NAME ||
                           ', 部門: ' || NVL(rec.DEPARTMENT_NAME, '未所属') ||
                           ', 場所: ' || NVL(rec.LOCATION_NAME, '不明'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    -- 例3: 外部結合とIN句の組み合わせ（修正版）
    DBMS_OUTPUT.PUT_LINE('3. 外部結合とIN句の組み合わせ:');
    FOR rec IN (
        SELECT e.EMPLOYEE_ID, e.EMPLOYEE_NAME, d.DEPARTMENT_NAME
        FROM T_0047_EMPLOYEES e
        LEFT OUTER JOIN T_0047_DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
                                             AND d.LOCATION_ID IN (SELECT LOCATION_ID FROM T_0047_LOCATIONS WHERE COUNTRY = '日本')
        ORDER BY e.EMPLOYEE_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.EMPLOYEE_ID ||
                           ', 名前: ' || rec.EMPLOYEE_NAME ||
                           ', 部門: ' || NVL(rec.DEPARTMENT_NAME, '未所属'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    -- 例4: 外部結合とEXISTS句の組み合わせ（修正版）
    DBMS_OUTPUT.PUT_LINE('4. 外部結合とEXISTS句の組み合わせ:');
    FOR rec IN (
        SELECT e.EMPLOYEE_ID, e.EMPLOYEE_NAME, d.DEPARTMENT_NAME
        FROM T_0047_EMPLOYEES e
        LEFT OUTER JOIN T_0047_DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
        WHERE EXISTS (
            SELECT 1
            FROM T_0047_PROJECTS p
            WHERE p.DEPARTMENT_ID = d.DEPARTMENT_ID
              AND p.END_DATE IS NULL
        ) OR d.DEPARTMENT_ID IS NULL
        ORDER BY e.EMPLOYEE_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.EMPLOYEE_ID ||
                           ', 名前: ' || rec.EMPLOYEE_NAME ||
                           ', 部門: ' || NVL(rec.DEPARTMENT_NAME, '未所属'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    -- 例5: 外部結合と相関サブクエリの組み合わせ（修正版）
    DBMS_OUTPUT.PUT_LINE('5. 外部結合と相関サブクエリの複雑な組み合わせ:');
    FOR rec IN (
        SELECT e.EMPLOYEE_ID, e.EMPLOYEE_NAME,
               d.DEPARTMENT_NAME AS DEPT_NAME,
               NVL((SELECT COUNT(*)
                   FROM T_0047_PROJECTS p
                   WHERE p.DEPARTMENT_ID = e.DEPARTMENT_ID), 0) AS PROJECT_COUNT
        FROM T_0047_EMPLOYEES e
        LEFT OUTER JOIN T_0047_DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
        WHERE e.SALARY > (SELECT AVG(SALARY) FROM T_0047_EMPLOYEES)
        ORDER BY e.EMPLOYEE_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.EMPLOYEE_ID ||
                           ', 名前: ' || rec.EMPLOYEE_NAME ||
                           ', 部門: ' || NVL(rec.DEPT_NAME, '未所属') ||
                           ', プロジェクト数: ' || rec.PROJECT_COUNT);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    -- 例6: 外部結合とCASE式の組み合わせ（修正版）
    DBMS_OUTPUT.PUT_LINE('6. 外部結合とCASE式の組み合わせ:');
    FOR rec IN (
        SELECT e.EMPLOYEE_ID, e.EMPLOYEE_NAME,
               CASE
                   WHEN d.DEPARTMENT_ID IS NULL THEN '未所属'
                   WHEN d.LOCATION_ID = 1 THEN d.DEPARTMENT_NAME || ' (東京)'
                   WHEN d.LOCATION_ID = 2 THEN d.DEPARTMENT_NAME || ' (NY)'
                   ELSE d.DEPARTMENT_NAME
               END AS DEPARTMENT_INFO,
               CASE
                   WHEN d.DEPARTMENT_ID IS NULL THEN 'プロジェクトなし'
                   WHEN EXISTS (SELECT 1 FROM T_0047_PROJECTS p WHERE p.DEPARTMENT_ID = d.DEPARTMENT_ID) THEN 'プロジェクトあり'
                   ELSE 'プロジェクトなし'
               END AS PROJECT_STATUS
        FROM T_0047_EMPLOYEES e
        LEFT OUTER JOIN T_0047_DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
        ORDER BY e.EMPLOYEE_ID
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.EMPLOYEE_ID ||
                           ', 名前: ' || rec.EMPLOYEE_NAME ||
                           ', 部門情報: ' || rec.DEPARTMENT_INFO ||
                           ', プロジェクト状況: ' || rec.PROJECT_STATUS);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===== レポート終了 =====');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0047_COMPLEX_OUTER_JOIN_REPORT;
/
