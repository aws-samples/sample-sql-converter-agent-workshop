-- テーブルの作成
CREATE TABLE T_0061_EMPLOYEES (
    EMPLOYEE_ID NUMBER PRIMARY KEY,
    FIRST_NAME VARCHAR2(50),
    LAST_NAME VARCHAR2(50),
    EMAIL VARCHAR2(100),
    PHONE_NUMBER VARCHAR2(20),
    HIRE_DATE DATE,
    JOB_ID VARCHAR2(10),
    SALARY NUMBER(8,2),
    COMMISSION_PCT NUMBER(2,2),
    MANAGER_ID NUMBER,
    DEPARTMENT_ID NUMBER
);

CREATE TABLE T_0061_DEPARTMENTS (
    DEPARTMENT_ID NUMBER PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR2(50),
    MANAGER_ID NUMBER,
    LOCATION_ID NUMBER
);

CREATE OR REPLACE PROCEDURE SCT_0061_MULTIPLE_BULK_COLLECT(
    p_department_id IN NUMBER DEFAULT NULL
)
IS
    -- 複数のコレクション型を定義
    TYPE t_emp_id_table IS TABLE OF T_0061_EMPLOYEES.EMPLOYEE_ID%TYPE;
    TYPE t_first_name_table IS TABLE OF T_0061_EMPLOYEES.FIRST_NAME%TYPE;
    TYPE t_last_name_table IS TABLE OF T_0061_EMPLOYEES.LAST_NAME%TYPE;
    TYPE t_email_table IS TABLE OF T_0061_EMPLOYEES.EMAIL%TYPE;
    TYPE t_salary_table IS TABLE OF T_0061_EMPLOYEES.SALARY%TYPE;
    TYPE t_dept_name_table IS TABLE OF T_0061_DEPARTMENTS.DEPARTMENT_NAME%TYPE;

    -- 複数のコレクション変数を宣言
    v_emp_ids t_emp_id_table;
    v_first_names t_first_name_table;
    v_last_names t_last_name_table;
    v_emails t_email_table;
    v_salaries t_salary_table;
    v_dept_names t_dept_name_table;

    -- 処理した行数を格納する変数
    v_row_count PLS_INTEGER;
BEGIN
    -- 複数のコレクション変数に対してBULK COLLECT INTO
    -- これがPostgreSQLに変換する際にエラーとなる部分
    SELECT e.EMPLOYEE_ID, e.FIRST_NAME, e.LAST_NAME, e.EMAIL, e.SALARY, d.DEPARTMENT_NAME
    BULK COLLECT INTO v_emp_ids, v_first_names, v_last_names, v_emails, v_salaries, v_dept_names
    FROM T_0061_EMPLOYEES e
    JOIN T_0061_DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
    WHERE (p_department_id IS NULL OR e.DEPARTMENT_ID = p_department_id)
    ORDER BY e.EMPLOYEE_ID;

    v_row_count := v_emp_ids.COUNT;
    DBMS_OUTPUT.PUT_LINE('取得した従業員数: ' || v_row_count);

    -- 結果を表示
    FOR i IN 1..v_row_count LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || v_emp_ids(i) ||
            ', 名前: ' || v_first_names(i) || ' ' || v_last_names(i) ||
            ', メール: ' || v_emails(i) ||
            ', 給与: ' || v_salaries(i) ||
            ', 部署: ' || v_dept_names(i)
        );
    END LOOP;

    -- 給与の合計と平均を計算
    DECLARE
        v_total_salary NUMBER := 0;
        v_avg_salary NUMBER;
    BEGIN
        FOR i IN 1..v_salaries.COUNT LOOP
            v_total_salary := v_total_salary + v_salaries(i);
        END LOOP;

        IF v_salaries.COUNT > 0 THEN
            v_avg_salary := v_total_salary / v_salaries.COUNT;
            DBMS_OUTPUT.PUT_LINE('給与合計: ' || v_total_salary);
            DBMS_OUTPUT.PUT_LINE('平均給与: ' || v_avg_salary);
        END IF;
    END;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0061_MULTIPLE_BULK_COLLECT;
/


CREATE OR REPLACE PROCEDURE SCT_0061_NESTED_BULK_COLLECT
IS
    -- コレクション型を定義
    TYPE t_dept_id_table IS TABLE OF T_0061_DEPARTMENTS.DEPARTMENT_ID%TYPE;
    TYPE t_dept_name_table IS TABLE OF T_0061_DEPARTMENTS.DEPARTMENT_NAME%TYPE;
    TYPE t_emp_id_table IS TABLE OF T_0061_EMPLOYEES.EMPLOYEE_ID%TYPE;
    TYPE t_emp_name_table IS TABLE OF VARCHAR2(100);
    TYPE t_emp_salary_table IS TABLE OF T_0061_EMPLOYEES.SALARY%TYPE;

    -- 部門情報用のコレクション
    v_dept_ids t_dept_id_table;
    v_dept_names t_dept_name_table;

    -- 従業員情報用のコレクション
    v_emp_ids t_emp_id_table;
    v_emp_names t_emp_name_table;
    v_emp_salaries t_emp_salary_table;

    -- 部門ごとの従業員数
    v_emp_count PLS_INTEGER;
BEGIN
    -- 部門情報を取得
    SELECT DEPARTMENT_ID, DEPARTMENT_NAME
    BULK COLLECT INTO v_dept_ids, v_dept_names
    FROM T_0061_DEPARTMENTS
    ORDER BY DEPARTMENT_ID;

    DBMS_OUTPUT.PUT_LINE('部門数: ' || v_dept_ids.COUNT);

    -- 各部門の従業員情報を取得
    FOR i IN 1..v_dept_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('===== 部門: ' || v_dept_names(i) || ' =====');

        -- 部門ごとに従業員情報をBULK COLLECT
        SELECT e.EMPLOYEE_ID, e.FIRST_NAME || ' ' || e.LAST_NAME, e.SALARY
        BULK COLLECT INTO v_emp_ids, v_emp_names, v_emp_salaries
        FROM T_0061_EMPLOYEES e
        WHERE e.DEPARTMENT_ID = v_dept_ids(i)
        ORDER BY e.EMPLOYEE_ID;

        v_emp_count := v_emp_ids.COUNT;
        DBMS_OUTPUT.PUT_LINE('従業員数: ' || v_emp_count);

        -- 従業員情報を表示
        FOR j IN 1..v_emp_count LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || v_emp_ids(j) ||
                ', 名前: ' || v_emp_names(j) ||
                ', 給与: ' || v_emp_salaries(j)
            );
        END LOOP;

        -- 部門の給与統計
        IF v_emp_count > 0 THEN
            DECLARE
                v_total_salary NUMBER := 0;
                v_max_salary NUMBER := 0;
                v_min_salary NUMBER := 999999;
            BEGIN
                FOR j IN 1..v_emp_count LOOP
                    v_total_salary := v_total_salary + v_emp_salaries(j);
                    v_max_salary := GREATEST(v_max_salary, v_emp_salaries(j));
                    v_min_salary := LEAST(v_min_salary, v_emp_salaries(j));
                END LOOP;

                DBMS_OUTPUT.PUT_LINE('部門給与合計: ' || v_total_salary);
                DBMS_OUTPUT.PUT_LINE('部門平均給与: ' || (v_total_salary / v_emp_count));
                DBMS_OUTPUT.PUT_LINE('部門最高給与: ' || v_max_salary);
                DBMS_OUTPUT.PUT_LINE('部門最低給与: ' || v_min_salary);
            END;
        END IF;

        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0061_NESTED_BULK_COLLECT;
/
