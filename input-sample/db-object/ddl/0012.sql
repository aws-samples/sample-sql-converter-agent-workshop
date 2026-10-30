-- テーブルの作成
CREATE TABLE T_0012 (
    EMPLOYEE_ID NUMBER PRIMARY KEY,
    EMPLOYEE_NAME VARCHAR2(100),
    MANAGER_ID NUMBER,
    JOB_TITLE VARCHAR2(100),
    HIRE_DATE DATE,
    SALARY NUMBER(10,2)
);

-- 階層クエリを使用したプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0012_HIERARCHY_QUERY(
    p_root_id IN NUMBER DEFAULT 1
)
IS
    -- 階層クエリを使用したカーソル
    CURSOR c_hierarchy IS
        SELECT
            EMPLOYEE_ID,
            EMPLOYEE_NAME,
            MANAGER_ID,
            JOB_TITLE,
            LEVEL AS HIERARCHY_LEVEL,
            LPAD(' ', (LEVEL-1)*2) || EMPLOYEE_NAME AS TREE_DISPLAY,
            CONNECT_BY_ROOT EMPLOYEE_NAME AS ROOT_EMPLOYEE,
            SYS_CONNECT_BY_PATH(EMPLOYEE_NAME, '/') AS PATH,
            CONNECT_BY_ISLEAF AS IS_LEAF
        FROM
            T_0012
        START WITH
            EMPLOYEE_ID = p_root_id
        CONNECT BY
            PRIOR EMPLOYEE_ID = MANAGER_ID
        ORDER SIBLINGS BY
            EMPLOYEE_NAME;

    -- レコード変数
    v_emp_rec c_hierarchy%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('組織階層の表示:');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');

    -- カーソルを開いて階層データを取得
    OPEN c_hierarchy;
    LOOP
        FETCH c_hierarchy INTO v_emp_rec;
        EXIT WHEN c_hierarchy%NOTFOUND;

        -- 階層データの表示
        DBMS_OUTPUT.PUT_LINE(
            'レベル: ' || v_emp_rec.HIERARCHY_LEVEL ||
            ', ID: ' || v_emp_rec.EMPLOYEE_ID ||
            ', 名前: ' || v_emp_rec.TREE_DISPLAY ||
            ', 役職: ' || v_emp_rec.JOB_TITLE ||
            CASE WHEN v_emp_rec.IS_LEAF = 1 THEN ', (リーフノード)' ELSE '' END
        );
    END LOOP;
    CLOSE c_hierarchy;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('パス情報:');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');

    -- パス情報を表示するためのカーソル
    DECLARE
        CURSOR c_paths IS
            SELECT
                EMPLOYEE_ID,
                EMPLOYEE_NAME,
                SYS_CONNECT_BY_PATH(EMPLOYEE_NAME, '/') AS PATH
            FROM
                T_0012
            START WITH
                EMPLOYEE_ID = p_root_id
            CONNECT BY
                PRIOR EMPLOYEE_ID = MANAGER_ID
            ORDER BY
                PATH;

        v_path_rec c_paths%ROWTYPE;
    BEGIN
        OPEN c_paths;
        LOOP
            FETCH c_paths INTO v_path_rec;
            EXIT WHEN c_paths%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || v_path_rec.EMPLOYEE_ID ||
                ', 名前: ' || v_path_rec.EMPLOYEE_NAME ||
                ', パス: ' || v_path_rec.PATH
            );
        END LOOP;
        CLOSE c_paths;
    END;

EXCEPTION
    WHEN OTHERS THEN
        IF c_hierarchy%ISOPEN THEN
            CLOSE c_hierarchy;
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0012_HIERARCHY_QUERY;
/
