-- PostgreSQL Database DDL Script

DROP TABLE IF EXISTS job_history CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP SEQUENCE IF EXISTS employee_seq;
DROP SEQUENCE IF EXISTS department_seq;

-- Departments table
CREATE TABLE departments (
    department_id INTEGER PRIMARY KEY,
    department_name VARCHAR(30) NOT NULL,
    manager_id INTEGER,
    location_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employees table
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(25) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    hire_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    job_id VARCHAR(10) NOT NULL,
    salary DECIMAL(8,2),
    commission_pct DECIMAL(4,2),
    manager_id INTEGER,
    department_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT emp_salary_min CHECK (salary > 0),
    CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Job history table
CREATE TABLE job_history (
    employee_id INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    job_id VARCHAR(10) NOT NULL,
    department_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT jhist_date_interval CHECK (end_date > start_date),
    CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Sequences
CREATE SEQUENCE employee_seq
    START WITH 1000
    INCREMENT BY 1
    NO CYCLE;

CREATE SEQUENCE department_seq
    START WITH 100
    INCREMENT BY 10
    NO CYCLE;

-- Indexes for performance
CREATE INDEX emp_department_ix ON employees (department_id);
CREATE INDEX emp_manager_ix ON employees (manager_id);
CREATE INDEX emp_name_ix ON employees (last_name, first_name);
CREATE INDEX emp_salary_ix ON employees (salary);
CREATE INDEX emp_hire_date_ix ON employees (hire_date);
CREATE INDEX emp_upper_email_ix ON employees (UPPER(email));
CREATE INDEX emp_job_ix ON employees (job_id);

-- Triggers for audit columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER employees_audit_trg
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER departments_audit_trg
    BEFORE UPDATE ON departments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Sample data
INSERT INTO departments VALUES (10, 'Administration', NULL, 1700, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO departments VALUES (20, 'Marketing', NULL, 1800, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO departments VALUES (50, 'Shipping', NULL, 1500, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO departments VALUES (60, 'IT', NULL, 1400, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO departments VALUES (80, 'Sales', NULL, 2500, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO departments VALUES (90, 'Executive', NULL, 1700, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Sample employees
INSERT INTO employees VALUES (100, 'Steven', 'King', 'SKING@company.com', '515.123.4567', 
    '2003-06-17'::TIMESTAMP, 'AD_PRES', 24000, NULL, NULL, 90, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO employees VALUES (101, 'Neena', 'Kochhar', 'NKOCHHAR@company.com', '515.123.4568', 
    '2005-09-21'::TIMESTAMP, 'AD_VP', 17000, NULL, 100, 90, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO employees VALUES (102, 'Lex', 'De Haan', 'LDEHAAN@company.com', '515.123.4569', 
    '2001-01-13'::TIMESTAMP, 'AD_VP', 17000, NULL, 100, 90, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO employees VALUES (103, 'Alexander', 'Hunold', 'AHUNOLD@company.com', '590.423.4567', 
    '2006-01-03'::TIMESTAMP, 'IT_PROG', 9000, NULL, 102, 60, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO employees VALUES (104, 'Bruce', 'Ernst', 'BERNST@company.com', '590.423.4568', 
    '2007-05-21'::TIMESTAMP, 'IT_PROG', 6000, NULL, 103, 60, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

