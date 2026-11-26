CREATE OR REPLACE PROCEDURE SCT_0060_collection_types_demo AS
    -- PL/SQL表（INDEX BY表）の定義
    TYPE idx_table_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    -- Nested Tableの定義
    TYPE nested_table_type IS TABLE OF VARCHAR2(100);

    -- 変数宣言
    v_idx_table idx_table_type;
    v_nested_table nested_table_type := nested_table_type();
BEGIN
    -- PL/SQL表にデータを格納
    v_idx_table(1) := '東京';
    v_idx_table(2) := '大阪';
    v_idx_table(3) := '名古屋';
    v_idx_table(10) := '福岡';  -- 非連続インデックスも可能

    -- Nested Tableにデータを格納
    v_nested_table.EXTEND(4);  -- 領域を確保
    v_nested_table(1) := '北海道';
    v_nested_table(2) := '沖縄';
    v_nested_table(3) := '京都';
    v_nested_table(4) := '広島';

    -- PL/SQL表の内容を表示
    DBMS_OUTPUT.PUT_LINE('PL/SQL表（INDEX BY表）の内容:');
    DBMS_OUTPUT.PUT_LINE('-------------------');

    FOR i IN v_idx_table.FIRST..v_idx_table.LAST LOOP
        IF v_idx_table.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE('インデックス ' || i || ': ' || v_idx_table(i));
        END IF;
    END LOOP;

    -- Nested Tableの内容を表示
    DBMS_OUTPUT.PUT_LINE('-------------------');
    DBMS_OUTPUT.PUT_LINE('Nested Tableの内容:');
    DBMS_OUTPUT.PUT_LINE('-------------------');

    FOR i IN 1..v_nested_table.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('インデックス ' || i || ': ' || v_nested_table(i));
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
