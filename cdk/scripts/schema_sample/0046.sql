CREATE TABLE T_0046 (
    customer_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100),
    phone_number VARCHAR2(20),
    credit_limit NUMBER(10,2),
    registration_date DATE,
    last_updated TIMESTAMP,
    CONSTRAINT email_unique UNIQUE (email)
) ORGANIZATION INDEX;
