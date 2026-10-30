CREATE TABLE T_0026 (
    employee_id NUMBER,
    employee_name VARCHAR2(100),
    department VARCHAR2(50),
    salary NUMBER,
    hire_date DATE
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DATA_PUMP_DIR
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
        DATE_FORMAT DATE MASK "YYYY-MM-DD"
        (
            employee_id,
            employee_name,
            department,
            salary,
            hire_date
        )
    )
    LOCATION ('T_0026_data.csv')
)
REJECT LIMIT UNLIMITED;
