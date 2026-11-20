-- テーブルの作成
CREATE TABLE T_0072 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- オーバーロードされたプロシージャ（同じ名前、異なるパラメータ）
-- プロシージャ1: 数値IDを受け取るバージョン
CREATE OR REPLACE PROCEDURE SCT_0072_GET_ITEM(
    p_id IN NUMBER,
    p_name OUT VARCHAR2,
    p_value OUT NUMBER
)
IS
BEGIN
    SELECT NAME, VALUE
    INTO p_name, p_value
    FROM T_0072
    WHERE ID = p_id;

    DBMS_OUTPUT.PUT_LINE('数値IDでアイテムを取得: ' || p_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_name := NULL;
        p_value := NULL;
        DBMS_OUTPUT.PUT_LINE('アイテムが見つかりません: ' || p_id);
END SCT_0072_GET_ITEM;
/

-- プロシージャ2: 文字列名を受け取るバージョン（オーバーロード）
CREATE OR REPLACE PROCEDURE SCT_0072_GET_ITEM(
    p_name IN VARCHAR2,
    p_id OUT NUMBER,
    p_value OUT NUMBER
)
IS
BEGIN
    SELECT ID, VALUE
    INTO p_id, p_value
    FROM T_0072
    WHERE NAME = p_name;

    DBMS_OUTPUT.PUT_LINE('名前でアイテムを取得: ' || p_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_id := NULL;
        p_value := NULL;
        DBMS_OUTPUT.PUT_LINE('アイテムが見つかりません: ' || p_name);
END SCT_0072_GET_ITEM;
/

-- プロシージャ3: 値の範囲を受け取るバージョン（オーバーロード）
CREATE OR REPLACE PROCEDURE SCT_0072_GET_ITEM(
    p_min_value IN NUMBER,
    p_max_value IN NUMBER,
    p_count OUT NUMBER
)
IS
BEGIN
    SELECT COUNT(*)
    INTO p_count
    FROM T_0072
    WHERE VALUE BETWEEN p_min_value AND p_max_value;

    DBMS_OUTPUT.PUT_LINE('値の範囲でアイテム数を取得: ' || p_min_value || ' - ' || p_max_value);
END SCT_0072_GET_ITEM;
/

-- 大文字小文字の違いのみのプロシージャ（PostgreSQLでは区別される）
CREATE OR REPLACE PROCEDURE SCT_0072_case_test(p_id IN NUMBER)
IS
    v_name VARCHAR2(100);
BEGIN
    SELECT NAME INTO v_name FROM T_0072 WHERE ID = p_id;
    DBMS_OUTPUT.PUT_LINE('小文字バージョン: ' || v_name);
END SCT_0072_case_test;
/

CREATE OR REPLACE PROCEDURE SCT_0072_CASE_TEST(p_id IN NUMBER)
IS
    v_name VARCHAR2(100);
BEGIN
    SELECT NAME INTO v_name FROM T_0072 WHERE ID = p_id;
    DBMS_OUTPUT.PUT_LINE('大文字バージョン: ' || v_name);
END SCT_0072_CASE_TEST;
/

-- パッケージ内の同名メソッド
CREATE OR REPLACE PACKAGE SCT_0072_PKG AS
    PROCEDURE PROCESS_ITEM(p_id IN NUMBER);
    PROCEDURE PROCESS_ITEM(p_name IN VARCHAR2);
    FUNCTION GET_ITEM_COUNT RETURN NUMBER;
END SCT_0072_PKG;
/

CREATE OR REPLACE PACKAGE BODY SCT_0072_PKG AS
    PROCEDURE PROCESS_ITEM(p_id IN NUMBER) IS
    BEGIN
        UPDATE T_0072 SET VALUE = VALUE + 10 WHERE ID = p_id;
        COMMIT;
    END PROCESS_ITEM;

    PROCEDURE PROCESS_ITEM(p_name IN VARCHAR2) IS
    BEGIN
        UPDATE T_0072 SET VALUE = VALUE + 20 WHERE NAME = p_name;
        COMMIT;
    END PROCESS_ITEM;

    FUNCTION GET_ITEM_COUNT RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM T_0072;
        RETURN v_count;
    END GET_ITEM_COUNT;
END SCT_0072_PKG;
/

