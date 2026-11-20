CREATE TABLE T_0064 (
    sale_id NUMBER NOT NULL,
    sale_date DATE NOT NULL,
    customer_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    CONSTRAINT t_0064_pk PRIMARY KEY (sale_id, sale_date)
)
PARTITION BY RANGE (sale_date) (
    PARTITION t_0064_2023_q1 VALUES LESS THAN (TO_DATE('2023-04-01', 'YYYY-MM-DD')),
    PARTITION t_0064_2023_q2 VALUES LESS THAN (TO_DATE('2023-07-01', 'YYYY-MM-DD')),
    PARTITION t_0064_2023_q3 VALUES LESS THAN (TO_DATE('2023-10-01', 'YYYY-MM-DD')),
    PARTITION t_0064_2023_q4 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION t_0064_future VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE T_0064_2 (
    detail_id NUMBER NOT NULL,
    sale_id NUMBER NOT NULL,
    sale_date DATE NOT NULL,  -- 親テーブルのパーティションキーも含める
    item_id NUMBER NOT NULL,
    item_description VARCHAR2(200),
    unit_price NUMBER(10,2) NOT NULL,
    discount_percent NUMBER(5,2),
    CONSTRAINT t_0064_2_details_pk PRIMARY KEY (detail_id),
    CONSTRAINT t_0064_2_details_fk FOREIGN KEY (sale_id, sale_date)
        REFERENCES T_0064 (sale_id, sale_date)
);
