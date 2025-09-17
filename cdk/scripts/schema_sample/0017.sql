-- ベーステーブルの作成
CREATE TABLE T_0017 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- マテリアライズドビューログの作成
CREATE MATERIALIZED VIEW LOG ON T_0017
WITH ROWID, PRIMARY KEY, SEQUENCE (NAME, VALUE, CREATED_DATE)
INCLUDING NEW VALUES;

-- マテリアライズドビューの作成（更新可能）
CREATE MATERIALIZED VIEW T_0017_MV
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
ENABLE QUERY REWRITE
AS
SELECT ID, NAME, VALUE, CREATED_DATE
FROM T_0017;

-- マテリアライズドビューに対してDML操作を行うプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0017_UPDATE_MATERIALIZED_VIEW(
    p_id IN NUMBER,
    p_new_value IN NUMBER
)
IS
    v_old_value NUMBER;
    v_count NUMBER;
BEGIN
    -- マテリアライズドビューから現在の値を取得
    SELECT VALUE INTO v_old_value
    FROM T_0017_MV
    WHERE ID = p_id;

    -- マテリアライズドビューを直接更新（PostgreSQLではサポートされていない）
    UPDATE T_0017_MV
    SET VALUE = p_new_value
    WHERE ID = p_id;

    -- 更新された行数を取得
    v_count := SQL%ROWCOUNT;

    -- 結果を表示
    DBMS_OUTPUT.PUT_LINE('マテリアライズドビューを更新しました。');
    DBMS_OUTPUT.PUT_LINE('ID: ' || p_id);
    DBMS_OUTPUT.PUT_LINE('旧値: ' || v_old_value);
    DBMS_OUTPUT.PUT_LINE('新値: ' || p_new_value);
    DBMS_OUTPUT.PUT_LINE('更新された行数: ' || v_count);

    -- コミット
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ID ' || p_id || ' のデータが見つかりません。');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        ROLLBACK;
END SCT_0017_UPDATE_MATERIALIZED_VIEW;
/

-- マテリアライズドビューに対して挿入を行うプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0017_INSERT_INTO_MATERIALIZED_VIEW(
    p_id IN NUMBER,
    p_name IN VARCHAR2,
    p_value IN NUMBER
)
IS
BEGIN
    -- マテリアライズドビューに直接挿入（PostgreSQLではサポートされていない）
    INSERT INTO T_0017_MV (ID, NAME, VALUE, CREATED_DATE)
    VALUES (p_id, p_name, p_value, SYSDATE);

    -- 結果を表示
    DBMS_OUTPUT.PUT_LINE('マテリアライズドビューに新しい行を挿入しました。');
    DBMS_OUTPUT.PUT_LINE('ID: ' || p_id);
    DBMS_OUTPUT.PUT_LINE('名前: ' || p_name);
    DBMS_OUTPUT.PUT_LINE('値: ' || p_value);

    -- コミット
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        ROLLBACK;
END SCT_0017_INSERT_INTO_MATERIALIZED_VIEW;
/

-- マテリアライズドビューから削除を行うプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0017_DELETE_FROM_MATERIALIZED_VIEW(
    p_id IN NUMBER
)
IS
    v_name VARCHAR2(100);
    v_value NUMBER;
BEGIN
    -- 削除前にデータを取得
    SELECT NAME, VALUE INTO v_name, v_value
    FROM T_0017_MV
    WHERE ID = p_id;

    -- マテリアライズドビューから直接削除（PostgreSQLではサポートされていない）
    DELETE FROM T_0017_MV
    WHERE ID = p_id;

    -- 結果を表示
    DBMS_OUTPUT.PUT_LINE('マテリアライズドビューから行を削除しました。');
    DBMS_OUTPUT.PUT_LINE('ID: ' || p_id);
    DBMS_OUTPUT.PUT_LINE('名前: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('値: ' || v_value);

    -- コミット
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ID ' || p_id || ' のデータが見つかりません。');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        ROLLBACK;
END SCT_0017_DELETE_FROM_MATERIALIZED_VIEW;
/
