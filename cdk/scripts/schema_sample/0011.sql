-- テーブルの作成
CREATE TABLE T_0011 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER(10,2),
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- %TYPE属性を使用したシンプルなプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0011_GET_EMPLOYEE_INFO(
    p_id IN T_0011.ID%TYPE,
    p_name OUT T_0011.NAME%TYPE,
    p_value OUT T_0011.VALUE%TYPE
)
IS
BEGIN
    -- テーブルからデータを取得
    SELECT NAME, VALUE
    INTO p_name, p_value
    FROM T_0011
    WHERE ID = p_id;

    -- 例外処理
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_name := NULL;
            p_value := NULL;
        WHEN OTHERS THEN
            RAISE;
END SCT_0011_GET_EMPLOYEE_INFO;
/
