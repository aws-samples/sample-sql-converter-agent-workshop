-- ハッシュクラスタの作成
CREATE CLUSTER T_0025_CLUSTER (
    department_id NUMBER(4)
)
SIZE 512
HASHKEYS 100;

-- ハッシュクラスタを使用する部門テーブルの作成
CREATE TABLE T_0025_DEPARTMENTS (
    department_id NUMBER(4) PRIMARY KEY,
    department_name VARCHAR2(30) NOT NULL,
    location_id NUMBER(4)
)
CLUSTER T_0025_CLUSTER (department_id);

-- ハッシュクラスタを使用する従業員テーブルの作成
CREATE TABLE T_0025_EMPLOYEES (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20),
    last_name VARCHAR2(25) NOT NULL,
    department_id NUMBER(4),
    job_id VARCHAR2(10),
    salary NUMBER(8,2),
    FOREIGN KEY (department_id) REFERENCES T_0025_DEPARTMENTS(department_id)
)
CLUSTER T_0025_CLUSTER (department_id);
