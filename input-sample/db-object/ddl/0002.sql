CREATE OR REPLACE PROCEDURE SCT_0002_process_any_data (
    p_data IN SYS.ANYDATA
) AS
    v_type_name VARCHAR2(100);
    v_result NUMBER;
    v_number NUMBER;
    v_varchar VARCHAR2(4000);
    v_date DATE;
BEGIN
    v_type_name := p_data.GETTYPENAME();
    DBMS_OUTPUT.PUT_LINE('Data type: ' || v_type_name);

    IF v_type_name = 'SYS.NUMBER' THEN
        v_result := p_data.GETNUMBER(v_number);
        DBMS_OUTPUT.PUT_LINE('Number value: ' || v_number);
    ELSIF v_type_name = 'SYS.VARCHAR2' THEN
        v_result := p_data.GETVARCHAR2(v_varchar);
        DBMS_OUTPUT.PUT_LINE('String value: ' || v_varchar);
    ELSIF v_type_name = 'SYS.DATE' THEN
        v_result := p_data.GETDATE(v_date);
        DBMS_OUTPUT.PUT_LINE('Date value: ' || TO_CHAR(v_date, 'YYYY-MM-DD'));
    ELSE
        DBMS_OUTPUT.PUT_LINE('Unsupported type');
    END IF;
END;
/

CREATE OR REPLACE TYPE SCT_0002_matrix_row_type AS VARRAY(10) OF NUMBER;
/

CREATE OR REPLACE TYPE SCT_0002_matrix_type AS VARRAY(10) OF SCT_0002_matrix_row_type;
/

CREATE OR REPLACE PROCEDURE SCT_0002_process_matrix (
    p_matrix IN SCT_0002_matrix_type
) AS
    v_sum NUMBER := 0;
BEGIN
    -- 2次元配列の処理
    FOR i IN 1..p_matrix.COUNT LOOP
        FOR j IN 1..p_matrix(i).COUNT LOOP
            v_sum := v_sum + p_matrix(i)(j);
            DBMS_OUTPUT.PUT_LINE('Matrix[' || i || ',' || j || '] = ' || p_matrix(i)(j));
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Matrix sum: ' || v_sum);
END;
/

CREATE OR REPLACE TYPE SCT_0002_item_type AS OBJECT (
    item_id NUMBER,
    item_name VARCHAR2(100),
    price NUMBER
);
/

CREATE OR REPLACE TYPE SCT_0002_item_list_type AS TABLE OF SCT_0002_item_type;
/

CREATE OR REPLACE TYPE SCT_0002_order_type AS OBJECT (
    order_id NUMBER,
    customer_name VARCHAR2(100),
    items SCT_0002_item_list_type,
    MEMBER FUNCTION get_total_price RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY SCT_0002_order_type AS
    MEMBER FUNCTION get_total_price RETURN NUMBER IS
        v_total NUMBER := 0;
    BEGIN
        FOR i IN 1..self.items.COUNT LOOP
            v_total := v_total + self.items(i).price;
        END LOOP;
        RETURN v_total;
    END;
END;
/

CREATE OR REPLACE PROCEDURE SCT_0002_process_order (
    p_order IN SCT_0002_order_type
) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Order total: ' || p_order.get_total_price());

    -- ネストされたコレクションの処理
    FOR i IN 1..p_order.items.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Item ' || i || ': ' || p_order.items(i).item_name);
    END LOOP;
END;
/

-- オブジェクト型の定義
CREATE OR REPLACE TYPE SCT_0002_address_type AS OBJECT (
    street VARCHAR2(100),
    city VARCHAR2(50),
    zip VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE SCT_0002_person_type AS OBJECT (
    id NUMBER,
    name VARCHAR2(100),
    addr SCT_0002_address_type,
    MEMBER FUNCTION get_full_address RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY SCT_0002_person_type AS
    MEMBER FUNCTION get_full_address RETURN VARCHAR2 IS
    BEGIN
        RETURN self.name || ': ' || self.addr.street || ', ' || self.addr.city || ' ' || self.addr.zip;
    END;
END;
/

-- プロシージャでの使用
CREATE OR REPLACE PROCEDURE SCT_0002_process_person (
    p_person IN SCT_0002_person_type
) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE(p_person.get_full_address());
END;
/

CREATE OR REPLACE PROCEDURE SCT_0002_dynamic_cursor_operations (
    p_table_name IN VARCHAR2
) AS
    TYPE t_rec IS REF CURSOR;
    v_cursor t_rec;
    v_cursor_array DBMS_SQL.VARCHAR2_TABLE;
    v_cursor_id INTEGER;
    v_dummy VARCHAR2(1000);
    v_column_count INTEGER;
    v_desc_tab DBMS_SQL.DESC_TAB;
BEGIN
    -- 動的SQLでカーソルを開く
    OPEN v_cursor FOR 'SELECT * FROM ' || p_table_name;

    -- REF CURSORをDBMS_SQL.PARSE用に変換
    v_cursor_id := DBMS_SQL.TO_CURSOR_NUMBER(v_cursor);

    -- カラム情報を取得
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_column_count, v_desc_tab);

    -- 各カラムを定義
    FOR i IN 1..v_column_count LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor_id, i, v_dummy, 1000);
    END LOOP;

    -- 結果を処理
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor_id) > 0 LOOP
        FOR i IN 1..v_column_count LOOP
            DBMS_SQL.COLUMN_VALUE(v_cursor_id, i, v_cursor_array(i));
            DBMS_OUTPUT.PUT_LINE('Column ' || i || ': ' || v_cursor_array(i));
        END LOOP;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
        RAISE;
END;
/
