CREATE TABLE T_0065 (
    transaction_id NUMBER NOT NULL,
    customer_id NUMBER,
    transaction_timestamp TIMESTAMP NOT NULL,
    amount NUMBER(12,2),
    transaction_type VARCHAR2(50),
    status VARCHAR2(20),
    description VARCHAR2(200),
    created_by VARCHAR2(50),
    CONSTRAINT transaction_history_pk PRIMARY KEY (transaction_id, transaction_timestamp)
)
PARTITION BY RANGE (transaction_timestamp) (
    PARTITION trans_2023_q1 VALUES LESS THAN (TIMESTAMP '2023-04-01 00:00:00'),
    PARTITION trans_2023_q2 VALUES LESS THAN (TIMESTAMP '2023-07-01 00:00:00'),
    PARTITION trans_2023_q3 VALUES LESS THAN (TIMESTAMP '2023-10-01 00:00:00'),
    PARTITION trans_2023_q4 VALUES LESS THAN (TIMESTAMP '2024-01-01 00:00:00'),
    PARTITION trans_future VALUES LESS THAN (MAXVALUE)
);
