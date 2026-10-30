-- Oracle Database DDL Script

DROP TABLE job_history ;
DROP TABLE employees ;
DROP TABLE departments ;
DROP SEQUENCE employee_seq ;
DROP SEQUENCE department_seq ;

-- Departments table
CREATE TABLE departments (
    department_id NUMBER(6) PRIMARY KEY,
    department_name VARCHAR2(30) NOT NULL,
    manager_id NUMBER(6),
    location_id NUMBER(4),
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE
);

-- Employees table
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(20),
    last_name VARCHAR2(25) NOT NULL,
    email VARCHAR2(25) NOT NULL UNIQUE,
    phone_number VARCHAR2(20),
    hire_date TIMESTAMP DEFAULT SYSDATE,
    job_id VARCHAR2(10) NOT NULL,
    salary NUMBER(8,2),
    commission_pct NUMBER(2,2),
    manager_id NUMBER(6),
    department_id NUMBER(6),
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT emp_salary_min CHECK (salary > 0),
    CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Job history table
CREATE TABLE job_history (
    employee_id NUMBER(6) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    job_id VARCHAR2(10) NOT NULL,
    department_id NUMBER(6),
    created_at TIMESTAMP DEFAULT SYSDATE,
    CONSTRAINT jhist_date_interval CHECK (end_date > start_date),
    CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Sequences (Oracle specific)
CREATE SEQUENCE employee_seq
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE department_seq
    START WITH 100
    INCREMENT BY 10
    NOCACHE
    NOCYCLE;

-- Indexes for performance
CREATE INDEX emp_department_ix ON employees (department_id);
CREATE INDEX emp_manager_ix ON employees (manager_id);
CREATE INDEX emp_name_ix ON employees (last_name, first_name);
CREATE INDEX emp_salary_ix ON employees (salary);
CREATE INDEX emp_hire_date_ix ON employees (hire_date);

-- Function-based index (Oracle specific)
CREATE INDEX emp_upper_email_ix ON employees (UPPER(email));

-- Bitmap index for low cardinality columns (Oracle specific)
CREATE BITMAP INDEX emp_job_bitmap_ix ON employees (job_id);

-- Triggers for audit columns
CREATE OR REPLACE TRIGGER employees_audit_trg
    BEFORE UPDATE ON employees
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER departments_audit_trg
    BEFORE UPDATE ON departments
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END;
/

-- Sample data
INSERT INTO departments VALUES (10, 'Administration', NULL, 1700, SYSDATE, SYSDATE);
INSERT INTO departments VALUES (20, 'Marketing', NULL, 1800, SYSDATE, SYSDATE);
INSERT INTO departments VALUES (50, 'Shipping', NULL, 1500, SYSDATE, SYSDATE);
INSERT INTO departments VALUES (60, 'IT', NULL, 1400, SYSDATE, SYSDATE);
INSERT INTO departments VALUES (80, 'Sales', NULL, 2500, SYSDATE, SYSDATE);
INSERT INTO departments VALUES (90, 'Executive', NULL, 1700, SYSDATE, SYSDATE);

-- Sample employees
INSERT INTO employees VALUES (100, 'Steven', 'King', 'SKING@company.com', '515.123.4567', 
    TO_TIMESTAMP('2003-06-17', 'YYYY-MM-DD'), 'AD_PRES', 24000, NULL, NULL, 90, SYSDATE, SYSDATE);

INSERT INTO employees VALUES (101, 'Neena', 'Kochhar', 'NKOCHHAR@company.com', '515.123.4568', 
    TO_TIMESTAMP('2005-09-21', 'YYYY-MM-DD'), 'AD_VP', 17000, NULL, 100, 90, SYSDATE, SYSDATE);

INSERT INTO employees VALUES (102, 'Lex', 'De Haan', 'LDEHAAN@company.com', '515.123.4569', 
    TO_TIMESTAMP('2001-01-13', 'YYYY-MM-DD'), 'AD_VP', 17000, NULL, 100, 90, SYSDATE, SYSDATE);

INSERT INTO employees VALUES (103, 'Alexander', 'Hunold', 'AHUNOLD@company.com', '590.423.4567', 
    TO_TIMESTAMP('2006-01-03', 'YYYY-MM-DD'), 'IT_PROG', 9000, NULL, 102, 60, SYSDATE, SYSDATE);

INSERT INTO employees VALUES (104, 'Bruce', 'Ernst', 'BERNST@company.com', '590.423.4568', 
    TO_TIMESTAMP('2007-05-21', 'YYYY-MM-DD'), 'IT_PROG', 6000, NULL, 103, 60, SYSDATE, SYSDATE);

COMMIT;

exit ;

