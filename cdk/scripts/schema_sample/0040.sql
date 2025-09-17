-- VIRTUAL COLUMNを使用したテーブルの作成
CREATE TABLE T_0040 (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    unit_price NUMBER(10,2) NOT NULL,
    quantity NUMBER NOT NULL,
    discount_rate NUMBER(4,2) DEFAULT 0,
    -- 仮想列（計算列）の定義
    subtotal NUMBER GENERATED ALWAYS AS (unit_price * quantity) VIRTUAL,
    discount_amount NUMBER GENERATED ALWAYS AS (unit_price * quantity * discount_rate / 100) VIRTUAL,
    total_price NUMBER GENERATED ALWAYS AS (unit_price * quantity * (1 - discount_rate / 100)) VIRTUAL,
    -- 税率10%を適用した税込み価格
    tax_amount NUMBER GENERATED ALWAYS AS (unit_price * quantity * (1 - discount_rate / 100) * 0.1) VIRTUAL,
    price_with_tax NUMBER GENERATED ALWAYS AS (unit_price * quantity * (1 - discount_rate / 100) * 1.1) VIRTUAL,
    -- 文字列連結の仮想列
    product_summary VARCHAR2(200) GENERATED ALWAYS AS (product_name || ' - ' || TO_CHAR(unit_price, '9,999,999.99') || '円 x ' || quantity || '個') VIRTUAL,
    created_date DATE DEFAULT SYSDATE,
    last_updated DATE DEFAULT SYSDATE
);
