-- 1. 住所を表すオブジェクト型の作成
CREATE OR REPLACE TYPE T_0033_ADDRESS_TYPE AS OBJECT (
    street VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(50),
    postal_code VARCHAR2(20)
);
/

-- 2. 電話番号を表すオブジェクト型の作成
CREATE OR REPLACE TYPE T_0033_PHONE_TYPE AS OBJECT (
    phone_type VARCHAR2(20),
    phone_number VARCHAR2(20)
);
/

-- 3. 電話番号のコレクション型（ネストテーブル型）の作成
CREATE OR REPLACE TYPE T_0033_PHONE_TABLE_TYPE AS TABLE OF T_0033_PHONE_TYPE;
/

-- 4. 顧客テーブルの作成
CREATE TABLE T_0033 (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100),
    address T_0033_ADDRESS_TYPE,
    phone_numbers T_0033_PHONE_TABLE_TYPE
) NESTED TABLE phone_numbers STORE AS T_0033_PHONE_NUMBERS_NT;

-- 6. ネストテーブル型を含むビューの作成
CREATE OR REPLACE VIEW T_0033_VIEW AS
SELECT
    c.customer_id,
    c.customer_name,
    c.address,
    c.phone_numbers
FROM T_0033 c;

CREATE OR REPLACE VIEW T_0033_VIEW2 AS
SELECT
    p.phone_type,
    p.phone_number
FROM T_0033_VIEW v,
     TABLE(v.phone_numbers) p;
