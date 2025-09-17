-- テーブルの作成
CREATE TABLE T_0030 (
    EMPLOYEE_ID NUMBER PRIMARY KEY,
    EMPLOYEE_NAME VARCHAR2(100),
    DEPARTMENT VARCHAR2(50),
    SALARY NUMBER(10,2),
    HIRE_DATE DATE
);

-- 独自のREF CURSOR型を定義したプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0030_GET_EMPLOYEES_TYPED(
    p_department IN VARCHAR2,
    p_cursor OUT SYS_REFCURSOR
)
IS
    -- 独自のREF CURSOR型を定義
    TYPE emp_cursor_type IS REF CURSOR RETURN T_0030%ROWTYPE;
    v_emp_cursor emp_cursor_type;
BEGIN
    -- 部署が指定されている場合はフィルタリング、そうでなければ全件取得
    IF p_department IS NOT NULL THEN
        OPEN v_emp_cursor FOR
            SELECT *
            FROM T_0030
            WHERE DEPARTMENT = p_department
            ORDER BY EMPLOYEE_ID;
    ELSE
        OPEN v_emp_cursor FOR
            SELECT *
            FROM T_0030
            ORDER BY EMPLOYEE_ID;
    END IF;

    -- 出力パラメータに代入
    p_cursor := v_emp_cursor;
END SCT_0030_GET_EMPLOYEES_TYPED;
/
