-- ------------ Write CREATE-DATABASE-stage scripts -----------

CREATE SCHEMA IF NOT EXISTS schema_sample;

-- ------------ Write CREATE-SEQUENCE-stage scripts -----------

CREATE SEQUENCE IF NOT EXISTS schema_sample.t_0015_log_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE
CACHE 20;

CREATE SEQUENCE IF NOT EXISTS schema_sample.t_0041_audit_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE
CACHE 20;

CREATE SEQUENCE IF NOT EXISTS schema_sample.t_0068_log_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE
CACHE 1;

CREATE SEQUENCE IF NOT EXISTS schema_sample.t_0069_log_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 9223372036854775807
MINVALUE 1
NO CYCLE
CACHE 20;

-- ------------ Write CREATE-TYPE-stage scripts -----------

CREATE TYPE schema_sample.null$c_paths AS (
employee_id DOUBLE PRECISION,
employee_name CHARACTER VARYING(100),
path CHARACTER VARYING(8000)
);

CREATE TYPE schema_sample.sct_0001_process_nested_table$item_list_type$c AS (
column_value CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0002_address_type AS (
street CHARACTER VARYING(100),
city CHARACTER VARYING(50),
zip CHARACTER VARYING(10)
);

CREATE TYPE schema_sample.sct_0002_item_type AS (
item_id DOUBLE PRECISION,
item_name CHARACTER VARYING(100),
price DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0002_matrix_row_type$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0002_matrix_type$c AS (
column_value schema_sample.sct_0002_matrix_row_type
);

CREATE TYPE schema_sample.sct_0002_order_type AS (
order_id DOUBLE PRECISION,
customer_name CHARACTER VARYING(100),
items schema_sample.sct_0002_item_list_type
);

CREATE TYPE schema_sample.sct_0002_person_type AS (
id DOUBLE PRECISION,
name CHARACTER VARYING(100),
addr schema_sample.sct_0002_address_type
);

CREATE TYPE schema_sample.sct_0008_json_array_demo$t_rec$r AS (
id DOUBLE PRECISION,
name CHARACTER VARYING(100),
json_data VARCHAR(8000)
);

CREATE TYPE schema_sample.sct_0012_hierarchy_query$c_hierarchy AS (
employee_id DOUBLE PRECISION,
employee_name CHARACTER VARYING(100),
manager_id DOUBLE PRECISION,
job_title CHARACTER VARYING(100),
level NUMERIC(38),
tree_display CHARACTER VARYING(8000),
root_employee CHARACTER VARYING(100),
path CHARACTER VARYING(8000),
connect_by_isleaf NUMERIC(38)
);

CREATE TYPE schema_sample.sct_0016_dynamic_bulk_collect$t_record$r AS (
id DOUBLE PRECISION,
name CHARACTER VARYING(100),
value DOUBLE PRECISION,
created_date TIMESTAMP(0) WITHOUT TIME ZONE
);

CREATE TYPE schema_sample.sct_0019_process_orders$t_order_id_tab$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0019_process_orders$t_order_rec$r AS (
product_id DOUBLE PRECISION,
order_quantity DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0019_process_orders$t_product_id_tab$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0019_process_orders$t_product_name_tab$c AS (
column_value CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0019_process_orders$t_stock_qty_tab$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0020_simple_forall$t_id_tab$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0020_simple_forall$t_value_tab$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0042_demo_cursor_already_open$c_items AS (
id DOUBLE PRECISION,
name CHARACTER VARYING(100),
value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0060_collection_types_demo$idx_table_type$c AS (
column_value CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0060_collection_types_demo$nested_table_type$c AS (
column_value CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0061_multiple_bulk_collect$t_dept_name_table$c AS (
column_value CHARACTER VARYING(50)
);

CREATE TYPE schema_sample.sct_0061_multiple_bulk_collect$t_email_table$c AS (
column_value CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0061_multiple_bulk_collect$t_emp_id_table$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0061_multiple_bulk_collect$t_first_name_table$c AS (
column_value CHARACTER VARYING(50)
);

CREATE TYPE schema_sample.sct_0061_multiple_bulk_collect$t_last_name_table$c AS (
column_value CHARACTER VARYING(50)
);

CREATE TYPE schema_sample.sct_0061_multiple_bulk_collect$t_salary_table$c AS (
column_value NUMERIC(8,2)
);

CREATE TYPE schema_sample.sct_0061_nested_bulk_collect$t_dept_id_table$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0061_nested_bulk_collect$t_dept_name_table$c AS (
column_value CHARACTER VARYING(50)
);

CREATE TYPE schema_sample.sct_0061_nested_bulk_collect$t_emp_id_table$c AS (
column_value DOUBLE PRECISION
);

CREATE TYPE schema_sample.sct_0061_nested_bulk_collect$t_emp_name_table$c AS (
column_value CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0061_nested_bulk_collect$t_emp_salary_table$c AS (
column_value NUMERIC(8,2)
);

CREATE TYPE schema_sample.sct_0062_data_obj_type AS (
id DOUBLE PRECISION,
value CHARACTER VARYING(100),
calc_date TIMESTAMP(0) WITHOUT TIME ZONE
);

CREATE TYPE schema_sample.sct_0071_cursor_sync_issue_demo$main_cursor AS (
data CHARACTER VARYING(8000)
);

CREATE TYPE schema_sample.sct_0074_collate_sort$c_japanese_sort AS (
id DOUBLE PRECISION,
name CHARACTER VARYING(100),
kana CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0074_nlssort_japanese$c_japanese_sort AS (
id DOUBLE PRECISION,
name CHARACTER VARYING(100),
kana CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.sct_0075_forall$noorderedlisttype$c AS (
column_value NUMERIC(6,0)
);

CREATE TYPE schema_sample.sct_0075_forall$prodlisttype$c AS (
column_value NUMERIC(6,0)
);

CREATE TYPE schema_sample.sct_0075_forall$warehouselisttype$c AS (
column_value NUMERIC(6,0)
);

CREATE TYPE schema_sample.t_0024_person_type AS (
person_id DOUBLE PRECISION,
first_name CHARACTER VARYING(50),
last_name CHARACTER VARYING(50),
birth_date TIMESTAMP(0) WITHOUT TIME ZONE,
phone_number CHARACTER VARYING(20),
email CHARACTER VARYING(100)
);

CREATE TYPE schema_sample.t_0033_address_type AS (
street CHARACTER VARYING(100),
city CHARACTER VARYING(50),
state CHARACTER VARYING(50),
postal_code CHARACTER VARYING(20)
);

CREATE TYPE schema_sample.t_0033_phone_type AS (
phone_type CHARACTER VARYING(20),
phone_number CHARACTER VARYING(20)
);

-- ------------ Write CREATE-DOMAIN-stage scripts -----------

CREATE DOMAIN schema_sample.sct_0001_process_nested_table$item_list_type AS CHARACTER VARYING(100) [];

CREATE DOMAIN schema_sample.sct_0002_item_list_type AS schema_sample.sct_0002_item_type [];

CREATE DOMAIN schema_sample.sct_0002_matrix_row_type AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0002_matrix_type AS schema_sample.sct_0002_matrix_row_type [];

CREATE DOMAIN schema_sample.sct_0008_json_array_demo$t_rec AS schema_sample.sct_0008_json_array_demo$t_rec$r;

CREATE DOMAIN schema_sample.sct_0016_dynamic_bulk_collect$t_record AS schema_sample.sct_0016_dynamic_bulk_collect$t_record$r;

CREATE DOMAIN schema_sample.sct_0016_dynamic_bulk_collect$t_record_table AS schema_sample.sct_0016_dynamic_bulk_collect$t_record$r [];

CREATE DOMAIN schema_sample.sct_0019_process_orders$t_order_id_tab AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0019_process_orders$t_order_rec AS schema_sample.sct_0019_process_orders$t_order_rec$r;

CREATE DOMAIN schema_sample.sct_0019_process_orders$t_order_tab AS schema_sample.sct_0019_process_orders$t_order_rec$r [];

CREATE DOMAIN schema_sample.sct_0019_process_orders$t_product_id_tab AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0019_process_orders$t_product_name_tab AS CHARACTER VARYING(100) [];

CREATE DOMAIN schema_sample.sct_0019_process_orders$t_stock_qty_tab AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0020_simple_forall$t_id_tab AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0020_simple_forall$t_value_tab AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0060_collection_types_demo$nested_table_type AS CHARACTER VARYING(100) [];

CREATE DOMAIN schema_sample.sct_0061_multiple_bulk_collect$t_dept_name_table AS CHARACTER VARYING(50) [];

CREATE DOMAIN schema_sample.sct_0061_multiple_bulk_collect$t_email_table AS CHARACTER VARYING(100) [];

CREATE DOMAIN schema_sample.sct_0061_multiple_bulk_collect$t_emp_id_table AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0061_multiple_bulk_collect$t_first_name_table AS CHARACTER VARYING(50) [];

CREATE DOMAIN schema_sample.sct_0061_multiple_bulk_collect$t_last_name_table AS CHARACTER VARYING(50) [];

CREATE DOMAIN schema_sample.sct_0061_multiple_bulk_collect$t_salary_table AS NUMERIC(8,2) [];

CREATE DOMAIN schema_sample.sct_0061_nested_bulk_collect$t_dept_id_table AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0061_nested_bulk_collect$t_dept_name_table AS CHARACTER VARYING(50) [];

CREATE DOMAIN schema_sample.sct_0061_nested_bulk_collect$t_emp_id_table AS DOUBLE PRECISION [];

CREATE DOMAIN schema_sample.sct_0061_nested_bulk_collect$t_emp_name_table AS CHARACTER VARYING(100) [];

CREATE DOMAIN schema_sample.sct_0061_nested_bulk_collect$t_emp_salary_table AS NUMERIC(8,2) [];

CREATE DOMAIN schema_sample.sct_0062_data_tab_type AS schema_sample.sct_0062_data_obj_type [];

CREATE DOMAIN schema_sample.sct_0075_forall$noorderedlisttype AS NUMERIC(6,0) [];

CREATE DOMAIN schema_sample.sct_0075_forall$prodlisttype AS NUMERIC(6,0) [];

CREATE DOMAIN schema_sample.sct_0075_forall$warehouselisttype AS NUMERIC(6,0) [];

CREATE DOMAIN schema_sample.t_0033_phone_table_type AS schema_sample.t_0033_phone_type [];

-- ------------ Write CREATE-TABLE-stage scripts -----------

CREATE TABLE schema_sample.dr$t_0028_text_idx$b(
    min_docid NUMERIC,
    max_docid NUMERIC,
    status NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.dr$t_0028_text_idx$c(
    dml_scn NUMERIC,
    dml_id NUMERIC,
    dml_op NUMERIC,
    dml_rid CHARACTER(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.dr$t_0028_text_idx$i(
    token_text CHARACTER VARYING(255) NOT NULL,
    token_type BIGINT NOT NULL,
    token_first BIGINT NOT NULL,
    token_last BIGINT NOT NULL,
    token_count BIGINT NOT NULL,
    token_info BYTEA
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.dr$t_0028_text_idx$k(
    docid NUMERIC,
    textkey CHARACTER(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.dr$t_0028_text_idx$n(
    nlt_docid NUMERIC(38,0) NOT NULL,
    nlt_mark CHARACTER(1) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.dr$t_0028_text_idx$q(
    dml_id NUMERIC,
    dml_op NUMERIC,
    dml_rid CHARACTER(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.dr$t_0028_text_idx$u(
    rid CHARACTER(255) NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.sct_0001_combine_type(
    c1 CHARACTER VARYING(1),
    c2 CHARACTER(1),
    c3 JSONB,
    c4 INTEGER,
    c5 INTEGER
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.sct_0036_remote_table(
    id NUMERIC,
    data_value CHARACTER VARYING(1000)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.sct_0053_remote_table(
    id NUMERIC,
    data_value CHARACTER VARYING(1000)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0005(
    id NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0006(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100) NOT NULL,
    value NUMERIC,
    status CHARACTER VARYING(20),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0007(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100) NOT NULL,
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0008(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    json_data TEXT
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0009(
    id NUMERIC,
    c1 CHARACTER VARYING(100)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0010(
    id NUMERIC,
    c1 CHARACTER VARYING(100)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0011(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value DOUBLE PRECISION,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0012(
    employee_id NUMERIC NOT NULL,
    employee_name CHARACTER VARYING(100),
    manager_id NUMERIC,
    job_title CHARACTER VARYING(100),
    hire_date TIMESTAMP(0) WITHOUT TIME ZONE,
    salary DOUBLE PRECISION
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0013(
    employee_id NUMERIC NOT NULL,
    first_name CHARACTER VARYING(50),
    last_name CHARACTER VARYING(50),
    email CHARACTER VARYING(100),
    phone_number CHARACTER VARYING(20),
    hire_date TIMESTAMP(0) WITHOUT TIME ZONE,
    job_id CHARACTER VARYING(10),
    salary DOUBLE PRECISION,
    commission_pct DOUBLE PRECISION,
    manager_id NUMERIC,
    department_id NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0015(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    status CHARACTER VARYING(20),
    category CHARACTER VARYING(50),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0),
    updated_date TIMESTAMP(0) WITHOUT TIME ZONE,
    description TEXT,
    is_active INTEGER DEFAULT 1
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0015_log(
    log_id NUMERIC NOT NULL,
    operation CHARACTER VARYING(20),
    table_name CHARACTER VARYING(30),
    record_id NUMERIC,
    column_name CHARACTER VARYING(30),
    old_value CHARACTER VARYING(4000),
    new_value CHARACTER VARYING(4000),
    change_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0),
    changed_by CHARACTER VARYING(30)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0016(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0017(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0017_mv(
    id DOUBLE PRECISION NOT NULL,
    name CHARACTER VARYING(100),
    value DOUBLE PRECISION,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE
);

CREATE TABLE schema_sample.t_0019_orders(
    order_id NUMERIC NOT NULL,
    product_id NUMERIC,
    order_quantity NUMERIC,
    order_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0019_products(
    product_id NUMERIC NOT NULL,
    product_name CHARACTER VARYING(100),
    price DOUBLE PRECISION,
    stock_quantity NUMERIC,
    last_update_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0020_data(
    id NUMERIC NOT NULL,
    value NUMERIC,
    description CHARACTER VARYING(100)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0021_departments(
    dept_id NUMERIC NOT NULL,
    dept_name CHARACTER VARYING(100)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0021_employees(
    emp_id NUMERIC NOT NULL,
    emp_name CHARACTER VARYING(100),
    salary DOUBLE PRECISION
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0022(
    id NUMERIC NOT NULL,
    xml_data XML
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0023(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    status CHARACTER VARYING(20),
    value NUMERIC,
    last_updated TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0025_departments(
    department_id INTEGER NOT NULL,
    department_name CHARACTER VARYING(30) NOT NULL,
    location_id INTEGER
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0025_employees(
    employee_id INTEGER NOT NULL,
    first_name CHARACTER VARYING(20),
    last_name CHARACTER VARYING(25) NOT NULL,
    department_id INTEGER,
    job_id CHARACTER VARYING(10),
    salary DOUBLE PRECISION
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0027(
    id NUMERIC,
    b NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0028_documents(
    doc_id NUMERIC NOT NULL,
    title CHARACTER VARYING(200),
    author CHARACTER VARYING(100),
    doc_text TEXT,
    last_update TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0029(
    id NUMERIC,
    ts1 TIMESTAMP(6) WITHOUT TIME ZONE,
    ts2 TIMESTAMP(3) WITHOUT TIME ZONE,
    ts3 TIMESTAMP(6) WITHOUT TIME ZONE,
    ts4 TIMESTAMP(6) WITHOUT TIME ZONE,
    ts5 TIMESTAMP(6) WITH TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0030(
    employee_id NUMERIC NOT NULL,
    employee_name CHARACTER VARYING(100),
    department CHARACTER VARYING(50),
    salary DOUBLE PRECISION,
    hire_date TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0031(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    status CHARACTER VARYING(20),
    last_updated TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0032(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0033(
    customer_id NUMERIC NOT NULL,
    customer_name CHARACTER VARYING(100),
    address schema_sample.t_0033_address_type,
    phone_numbers schema_sample.t_0033_phone_table_type
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0034(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0035(
    id NUMERIC,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0035_ref(
    ref_id NUMERIC NOT NULL,
    ref_name CHARACTER VARYING(100)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0036_employees(
    employee_id NUMERIC,
    employee_name CHARACTER VARYING(100),
    manager_id NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0037(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    update_date TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0040(
    product_id NUMERIC NOT NULL,
    product_name CHARACTER VARYING(100) NOT NULL,
    unit_price DOUBLE PRECISION NOT NULL,
    quantity NUMERIC NOT NULL,
    discount_rate DOUBLE PRECISION DEFAULT 0,
    subtotal NUMERIC GENERATED ALWAYS AS (unit_price * quantity) STORED,
    discount_amount NUMERIC GENERATED ALWAYS AS (unit_price * quantity * discount_rate / 100::NUMERIC) STORED,
    total_price NUMERIC GENERATED ALWAYS AS (unit_price * quantity * (1 - discount_rate / 100::NUMERIC)) STORED,
    tax_amount NUMERIC GENERATED ALWAYS AS (unit_price * quantity * (1 - discount_rate / 100::NUMERIC) * 0.1) STORED,
    price_with_tax NUMERIC GENERATED ALWAYS AS (unit_price * quantity * (1 - discount_rate / 100::NUMERIC) * 1.1) STORED,
    product_summary CHARACTER VARYING(200),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0),
    last_updated TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0041(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    status CHARACTER VARYING(20),
    value NUMERIC,
    last_updated TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0041_audit(
    audit_id NUMERIC NOT NULL,
    table_name CHARACTER VARYING(30),
    operation CHARACTER VARYING(10),
    column_name CHARACTER VARYING(30),
    record_id NUMERIC,
    old_value CHARACTER VARYING(4000),
    new_value CHARACTER VARYING(4000),
    changed_by CHARACTER VARYING(30),
    change_date TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0042(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0046(
    customer_id BIGINT NOT NULL,
    first_name CHARACTER VARYING(50) NOT NULL,
    last_name CHARACTER VARYING(50) NOT NULL,
    email CHARACTER VARYING(100),
    phone_number CHARACTER VARYING(20),
    credit_limit DOUBLE PRECISION,
    registration_date TIMESTAMP(0) WITHOUT TIME ZONE,
    last_updated TIMESTAMP(6) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0047_departments(
    department_id NUMERIC NOT NULL,
    department_name CHARACTER VARYING(100),
    location_id NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0047_employees(
    employee_id NUMERIC NOT NULL,
    employee_name CHARACTER VARYING(100),
    department_id NUMERIC,
    salary DOUBLE PRECISION,
    hire_date TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0047_locations(
    location_id NUMERIC NOT NULL,
    location_name CHARACTER VARYING(100),
    country CHARACTER VARYING(50)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0047_projects(
    project_id NUMERIC NOT NULL,
    project_name CHARACTER VARYING(100),
    department_id NUMERIC,
    start_date TIMESTAMP(0) WITHOUT TIME ZONE,
    end_date TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0050(
    r CHARACTER(255)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0052(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    status CHARACTER VARYING(20),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0054(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0055_1(
    id NUMERIC NOT NULL,
    c1 NUMERIC,
    c2 NUMERIC,
    update_date TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0055_2(
    id NUMERIC NOT NULL,
    c1 NUMERIC,
    update_date TIMESTAMP(0) WITHOUT TIME ZONE
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0056(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    status CHARACTER VARYING(20),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0057_strings(
    id NUMERIC NOT NULL,
    input_string CHARACTER VARYING(200),
    processed_string CHARACTER VARYING(200)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0061_departments(
    department_id NUMERIC NOT NULL,
    department_name CHARACTER VARYING(50),
    manager_id NUMERIC,
    location_id NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0061_employees(
    employee_id NUMERIC NOT NULL,
    first_name CHARACTER VARYING(50),
    last_name CHARACTER VARYING(50),
    email CHARACTER VARYING(100),
    phone_number CHARACTER VARYING(20),
    hire_date TIMESTAMP(0) WITHOUT TIME ZONE,
    job_id CHARACTER VARYING(10),
    salary DOUBLE PRECISION,
    commission_pct DOUBLE PRECISION,
    manager_id NUMERIC,
    department_id NUMERIC
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0063(
    dt TIMESTAMP(0) WITHOUT TIME ZONE,
    c1 NUMERIC
)
    PARTITION BY RANGE (dt)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0064(
    sale_id NUMERIC NOT NULL,
    sale_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    customer_id NUMERIC NOT NULL,
    product_id NUMERIC NOT NULL,
    quantity NUMERIC NOT NULL,
    amount DOUBLE PRECISION NOT NULL
)
    PARTITION BY RANGE (sale_date)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0064_2(
    detail_id NUMERIC NOT NULL,
    sale_id NUMERIC NOT NULL,
    sale_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    item_id NUMERIC NOT NULL,
    item_description CHARACTER VARYING(200),
    unit_price DOUBLE PRECISION NOT NULL,
    discount_percent DOUBLE PRECISION
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0065(
    transaction_id NUMERIC NOT NULL,
    customer_id NUMERIC,
    transaction_timestamp TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    amount DOUBLE PRECISION,
    transaction_type CHARACTER VARYING(50),
    status CHARACTER VARYING(20),
    description CHARACTER VARYING(200),
    created_by CHARACTER VARYING(50)
)
    PARTITION BY RANGE (transaction_timestamp)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0066(
    id NUMERIC,
    name CHARACTER VARYING(100),
    description TEXT,
    document BYTEA,
    image_data BYTEA,
    xml_data XML,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0067_1(
    sale_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    sale_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    quantity INTEGER NOT NULL,
    amount DOUBLE PRECISION NOT NULL
)
    PARTITION BY RANGE (sale_date)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0067_2(
    transaction_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    transaction_amount DOUBLE PRECISION NOT NULL,
    transaction_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
)
    PARTITION BY RANGE (transaction_amount)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0067_3(
    order_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    order_date TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    region CHARACTER VARYING(20) NOT NULL,
    quantity INTEGER NOT NULL,
    price DOUBLE PRECISION NOT NULL
)
    PARTITION BY RANGE (order_date)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0068_error_log(
    log_id NUMERIC NOT NULL,
    error_code NUMERIC,
    error_message CHARACTER VARYING(4000),
    procedure_name CHARACTER VARYING(100),
    log_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0068_users(
    user_id NUMERIC NOT NULL,
    username CHARACTER VARYING(50),
    email CHARACTER VARYING(100),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0069(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0069_log(
    log_id NUMERIC NOT NULL,
    operation CHARACTER VARYING(10),
    table_name CHARACTER VARYING(30),
    record_id NUMERIC,
    log_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0070(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_by CHARACTER VARYING(30),
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0072(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    value NUMERIC,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0074(
    id NUMERIC NOT NULL,
    name CHARACTER VARYING(100),
    kana CHARACTER VARYING(100)
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0075(
    product_id INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    quantity_on_hand INTEGER NOT NULL
)
        WITH (
        OIDS=FALSE
        );

CREATE TABLE schema_sample.t_0076(
    id NUMERIC NOT NULL,
    filename CHARACTER VARYING(255),
    content TEXT,
    created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0),
    updated_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
)
        WITH (
        OIDS=FALSE
        );

-- ------------ Write CREATE-PARTITION-stage scripts -----------

CREATE TABLE schema_sample.t_0063_default
        PARTITION OF schema_sample.t_0063
        DEFAULT;

CREATE TABLE schema_sample.t_0063_p1_2019_q1
        PARTITION OF schema_sample.t_0063
        FOR VALUES FROM (MINVALUE) TO ('2019-04-01 00:00:00');

CREATE TABLE schema_sample.t_0063_p2_2019_q2
        PARTITION OF schema_sample.t_0063
        FOR VALUES FROM ('2019-04-01 00:00:00') TO ('2019-07-01 00:00:00');

CREATE TABLE schema_sample.t_0064_t_0064_2023_q1
        PARTITION OF schema_sample.t_0064
        FOR VALUES FROM (MINVALUE) TO ('2023-04-01 00:00:00');

CREATE TABLE schema_sample.t_0064_t_0064_2023_q2
        PARTITION OF schema_sample.t_0064
        FOR VALUES FROM ('2023-04-01 00:00:00') TO ('2023-07-01 00:00:00');

CREATE TABLE schema_sample.t_0064_t_0064_2023_q3
        PARTITION OF schema_sample.t_0064
        FOR VALUES FROM ('2023-07-01 00:00:00') TO ('2023-10-01 00:00:00');

CREATE TABLE schema_sample.t_0064_t_0064_2023_q4
        PARTITION OF schema_sample.t_0064
        FOR VALUES FROM ('2023-10-01 00:00:00') TO ('2024-01-01 00:00:00');

CREATE TABLE schema_sample.t_0064_t_0064_future
        PARTITION OF schema_sample.t_0064
        FOR VALUES FROM ('2024-01-01 00:00:00') TO (MAXVALUE);

CREATE TABLE schema_sample.t_0065_trans_2023_q1
        PARTITION OF schema_sample.t_0065
        FOR VALUES FROM (MINVALUE) TO ('2023-04-01 00:00:00');

CREATE TABLE schema_sample.t_0065_trans_2023_q2
        PARTITION OF schema_sample.t_0065
        FOR VALUES FROM ('2023-04-01 00:00:00') TO ('2023-07-01 00:00:00');

CREATE TABLE schema_sample.t_0065_trans_2023_q3
        PARTITION OF schema_sample.t_0065
        FOR VALUES FROM ('2023-07-01 00:00:00') TO ('2023-10-01 00:00:00');

CREATE TABLE schema_sample.t_0065_trans_2023_q4
        PARTITION OF schema_sample.t_0065
        FOR VALUES FROM ('2023-10-01 00:00:00') TO ('2024-01-01 00:00:00');

CREATE TABLE schema_sample.t_0065_trans_future
        PARTITION OF schema_sample.t_0065
        FOR VALUES FROM ('2024-01-01 00:00:00') TO (MAXVALUE);

CREATE TABLE schema_sample.t_0067_1_sales_p1
        PARTITION OF schema_sample.t_0067_1
        FOR VALUES FROM (MINVALUE) TO ('2023-01-01 00:00:00');

CREATE TABLE schema_sample.t_0067_1_sales_p2
        PARTITION OF schema_sample.t_0067_1
        FOR VALUES FROM ('2023-01-01 00:00:00') TO ('2023-02-01 00:00:00');

CREATE TABLE schema_sample.t_0067_1_sales_p3
        PARTITION OF schema_sample.t_0067_1
        FOR VALUES FROM ('2023-02-01 00:00:00') TO ('2023-03-01 00:00:00');

CREATE TABLE schema_sample.t_0067_2_trans_p1
        PARTITION OF schema_sample.t_0067_2
        FOR VALUES FROM (MINVALUE) TO (1000);

CREATE TABLE schema_sample.t_0067_2_trans_p2
        PARTITION OF schema_sample.t_0067_2
        FOR VALUES FROM (1000) TO (2000);

CREATE TABLE schema_sample.t_0067_2_trans_p3
        PARTITION OF schema_sample.t_0067_2
        FOR VALUES FROM (2000) TO (3000);

CREATE TABLE schema_sample.t_0067_3_order_p1
        PARTITION OF schema_sample.t_0067_3
        FOR VALUES FROM (MINVALUE) TO ('2023-01-01 00:00:00')
    PARTITION BY LIST (region);

CREATE TABLE schema_sample.t_0067_3_order_p2
        PARTITION OF schema_sample.t_0067_3
        FOR VALUES FROM ('2023-01-01 00:00:00') TO ('2023-01-08 00:00:00')
    PARTITION BY LIST (region);

CREATE TABLE schema_sample.t_0067_3_order_p3
        PARTITION OF schema_sample.t_0067_3
        FOR VALUES FROM ('2023-01-08 00:00:00') TO ('2023-01-15 00:00:00')
    PARTITION BY LIST (region);

-- ------------ Write CREATE-SUBPARTITION-stage scripts -----------

CREATE TABLE schema_sample.t_0067_3_order_p1_sp_east
        PARTITION OF schema_sample.t_0067_3_order_p1
        FOR VALUES IN ('EAST');

CREATE TABLE schema_sample.t_0067_3_order_p1_sp_north
        PARTITION OF schema_sample.t_0067_3_order_p1
        FOR VALUES IN ('NORTH');

CREATE TABLE schema_sample.t_0067_3_order_p1_sp_south
        PARTITION OF schema_sample.t_0067_3_order_p1
        FOR VALUES IN ('SOUTH');

CREATE TABLE schema_sample.t_0067_3_order_p1_sp_west
        PARTITION OF schema_sample.t_0067_3_order_p1
        FOR VALUES IN ('WEST');

CREATE TABLE schema_sample.t_0067_3_order_p2_sp_east
        PARTITION OF schema_sample.t_0067_3_order_p2
        FOR VALUES IN ('EAST');

CREATE TABLE schema_sample.t_0067_3_order_p2_sp_north
        PARTITION OF schema_sample.t_0067_3_order_p2
        FOR VALUES IN ('NORTH');

CREATE TABLE schema_sample.t_0067_3_order_p2_sp_south
        PARTITION OF schema_sample.t_0067_3_order_p2
        FOR VALUES IN ('SOUTH');

CREATE TABLE schema_sample.t_0067_3_order_p2_sp_west
        PARTITION OF schema_sample.t_0067_3_order_p2
        FOR VALUES IN ('WEST');

CREATE TABLE schema_sample.t_0067_3_order_p3_sp_east
        PARTITION OF schema_sample.t_0067_3_order_p3
        FOR VALUES IN ('EAST');

CREATE TABLE schema_sample.t_0067_3_order_p3_sp_north
        PARTITION OF schema_sample.t_0067_3_order_p3
        FOR VALUES IN ('NORTH');

CREATE TABLE schema_sample.t_0067_3_order_p3_sp_south
        PARTITION OF schema_sample.t_0067_3_order_p3
        FOR VALUES IN ('SOUTH');

CREATE TABLE schema_sample.t_0067_3_order_p3_sp_west
        PARTITION OF schema_sample.t_0067_3_order_p3
        FOR VALUES IN ('WEST');

-- ------------ Write CREATE-VIEW-stage scripts -----------

CREATE OR REPLACE  VIEW schema_sample.t_0013_view (employee_id, full_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id, department_name, years_of_service) AS
SELECT
    employee_id, CONCAT_WS('', first_name, ' ', last_name) AS full_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id,
    CASE
        WHEN department_id = 10 THEN '総務部'
        WHEN department_id = 20 THEN '営業部'
        WHEN department_id = 30 THEN '開発部'
        WHEN department_id = 40 THEN '人事部'
        ELSE '未所属'
    END AS department_name, ROUND(aws_oracle_ext.MONTHS_BETWEEN((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0), hire_date) / 12::NUMERIC, 1) AS years_of_service
    FROM schema_sample.t_0013;

CREATE OR REPLACE  VIEW schema_sample.t_0033_view (customer_id, customer_name, address, phone_numbers) AS
SELECT
    c.customer_id, c.customer_name, (c).address, (c).phone_numbers
    FROM schema_sample.t_0033 AS c;

CREATE OR REPLACE  VIEW schema_sample.t_0033_view2 (phone_type, phone_number) AS
SELECT
    p.phone_type, p.phone_number
    FROM schema_sample.t_0033_view AS v, aws_oracle_ext.table(pVal => (v).phone_numbers, pValType => 'NESTEDREC', pTypeToCast => 'schema_sample.t_0033_phone_type')
        AS (p schema_sample.t_0033_phone_type);

CREATE OR REPLACE  VIEW schema_sample.t_0034_view (id, name, value, created_date) AS
SELECT
    id, name, VALUE(), created_date
    FROM schema_sample.t_0034;

-- ------------ Write CREATE-INDEX-stage scripts -----------

CREATE INDEX dr$t_0028_text_idx$x
ON schema_sample.dr$t_0028_text_idx$i
USING BTREE (token_text ASC, token_type ASC, token_first ASC, token_last ASC, token_count ASC);

CREATE UNIQUE INDEX dr$t_0028_text_idx$kd
ON schema_sample.dr$t_0028_text_idx$k
USING BTREE (docid ASC, textkey ASC);

CREATE UNIQUE INDEX dr$t_0028_text_idx$kr
ON schema_sample.dr$t_0028_text_idx$k
USING BTREE (textkey ASC, docid ASC);

-- ------------ Write CREATE-CONSTRAINT-stage scripts -----------

ALTER TABLE schema_sample.dr$t_0028_text_idx$n
ADD PRIMARY KEY (nlt_docid);

ALTER TABLE schema_sample.dr$t_0028_text_idx$u
ADD PRIMARY KEY (rid);

ALTER TABLE schema_sample.t_0006
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0006
ADD CONSTRAINT t_0006_key CHECK (value > 0 AND status IN ('ACTIVE', 'INACTIVE', 'PENDING'));

ALTER TABLE schema_sample.t_0007
ADD CHECK (value >= 0);

ALTER TABLE schema_sample.t_0007
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0008
ADD CHECK (json_data IS JSON);

ALTER TABLE schema_sample.t_0008
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0011
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0012
ADD PRIMARY KEY (employee_id);

ALTER TABLE schema_sample.t_0013
ADD PRIMARY KEY (employee_id);

ALTER TABLE schema_sample.t_0015
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0015_log
ADD PRIMARY KEY (log_id);

ALTER TABLE schema_sample.t_0016
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0017
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0019_orders
ADD PRIMARY KEY (order_id);

ALTER TABLE schema_sample.t_0019_products
ADD PRIMARY KEY (product_id);

ALTER TABLE schema_sample.t_0020_data
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0021_departments
ADD PRIMARY KEY (dept_id);

ALTER TABLE schema_sample.t_0021_employees
ADD PRIMARY KEY (emp_id);

ALTER TABLE schema_sample.t_0022
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0023
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0025_departments
ADD PRIMARY KEY (department_id);

ALTER TABLE schema_sample.t_0025_employees
ADD PRIMARY KEY (employee_id);

ALTER TABLE schema_sample.t_0028_documents
ADD PRIMARY KEY (doc_id);

ALTER TABLE schema_sample.t_0030
ADD PRIMARY KEY (employee_id);

ALTER TABLE schema_sample.t_0031
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0032
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0033
ADD PRIMARY KEY (customer_id);

ALTER TABLE schema_sample.t_0034
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0035
ADD CONSTRAINT ck_t_0035_value CHECK (value > 0) NOT VALID;

ALTER TABLE schema_sample.t_0035
ADD CONSTRAINT pk_t_0035 PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0035
ADD CONSTRAINT uq_t_0035_name UNIQUE (name);

ALTER TABLE schema_sample.t_0035_ref
ADD PRIMARY KEY (ref_id);

ALTER TABLE schema_sample.t_0037
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0040
ADD PRIMARY KEY (product_id);

ALTER TABLE schema_sample.t_0041
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0041_audit
ADD PRIMARY KEY (audit_id);

ALTER TABLE schema_sample.t_0042
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0046
ADD CONSTRAINT email_unique UNIQUE (email);

ALTER TABLE schema_sample.t_0046
ADD PRIMARY KEY (customer_id);

ALTER TABLE schema_sample.t_0047_departments
ADD PRIMARY KEY (department_id);

ALTER TABLE schema_sample.t_0047_employees
ADD PRIMARY KEY (employee_id);

ALTER TABLE schema_sample.t_0047_locations
ADD PRIMARY KEY (location_id);

ALTER TABLE schema_sample.t_0047_projects
ADD PRIMARY KEY (project_id);

ALTER TABLE schema_sample.t_0052
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0054
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0055_1
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0055_2
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0056
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0057_strings
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0061_departments
ADD PRIMARY KEY (department_id);

ALTER TABLE schema_sample.t_0061_employees
ADD PRIMARY KEY (employee_id);

ALTER TABLE schema_sample.t_0064
ADD CONSTRAINT t_0064_pk PRIMARY KEY (sale_id, sale_date);

ALTER TABLE schema_sample.t_0064_2
ADD CONSTRAINT t_0064_2_details_pk PRIMARY KEY (detail_id);

ALTER TABLE schema_sample.t_0065
ADD CONSTRAINT transaction_history_pk PRIMARY KEY (transaction_id, transaction_timestamp);

ALTER TABLE schema_sample.t_0068_error_log
ADD PRIMARY KEY (log_id);

ALTER TABLE schema_sample.t_0068_users
ADD PRIMARY KEY (user_id);

ALTER TABLE schema_sample.t_0068_users
ADD UNIQUE (username);

ALTER TABLE schema_sample.t_0068_users
ADD UNIQUE (email);

ALTER TABLE schema_sample.t_0069
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0069_log
ADD PRIMARY KEY (log_id);

ALTER TABLE schema_sample.t_0070
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0072
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0074
ADD PRIMARY KEY (id);

ALTER TABLE schema_sample.t_0075
ADD CONSTRAINT inventory_pk PRIMARY KEY (product_id, warehouse_id);

ALTER TABLE schema_sample.t_0076
ADD PRIMARY KEY (id);

-- ------------ Write CREATE-FOREIGN-KEY-CONSTRAINT-stage scripts -----------

ALTER TABLE schema_sample.t_0019_orders
ADD FOREIGN KEY (product_id) 
REFERENCES schema_sample.t_0019_products (product_id)
ON DELETE NO ACTION;

ALTER TABLE schema_sample.t_0025_employees
ADD FOREIGN KEY (department_id) 
REFERENCES schema_sample.t_0025_departments (department_id)
ON DELETE NO ACTION;

ALTER TABLE schema_sample.t_0035
ADD CONSTRAINT fk_t_0035_ref_id FOREIGN KEY (id) 
REFERENCES schema_sample.t_0035_ref (ref_id)
ON DELETE NO ACTION NOT VALID;

-- ------------ Write CREATE-FUNCTION-stage scripts -----------

CREATE OR REPLACE FUNCTION schema_sample.sct_0002_address_type(IN street CHARACTER VARYING DEFAULT NULL, IN city CHARACTER VARYING DEFAULT NULL, IN zip CHARACTER VARYING DEFAULT NULL)
RETURNS schema_sample.sct_0002_address_type
AS
$BODY$
SELECT ROW(street,city,zip)::schema_sample.sct_0002_address_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0002_item_type(IN item_id DOUBLE PRECISION DEFAULT NULL, IN item_name CHARACTER VARYING DEFAULT NULL, IN price DOUBLE PRECISION DEFAULT NULL)
RETURNS schema_sample.sct_0002_item_type
AS
$BODY$
SELECT ROW(item_id,item_name,price)::schema_sample.sct_0002_item_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0002_order_type(IN order_id DOUBLE PRECISION DEFAULT NULL, IN customer_name CHARACTER VARYING DEFAULT NULL, IN items schema_sample.sct_0002_item_list_type DEFAULT NULL)
RETURNS schema_sample.sct_0002_order_type
AS
$BODY$
SELECT ROW(order_id,customer_name,items)::schema_sample.sct_0002_order_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0002_person_type(IN id DOUBLE PRECISION DEFAULT NULL, IN name CHARACTER VARYING DEFAULT NULL, IN addr schema_sample.sct_0002_address_type DEFAULT schema_sample.sct_0002_address_type())
RETURNS schema_sample.sct_0002_person_type
AS
$BODY$
SELECT ROW(id,name,addr)::schema_sample.sct_0002_person_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0008_json_array_demo$t_rec(IN id DOUBLE PRECISION DEFAULT NULL, IN name TEXT DEFAULT NULL, IN json_data CHARACTER VARYING DEFAULT NULL)
RETURNS schema_sample.sct_0008_json_array_demo$t_rec
AS
$BODY$
SELECT
    ROW (id, name, json_data)::schema_sample.sct_0008_json_array_demo$t_rec;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0016_dynamic_bulk_collect$t_record(IN id DOUBLE PRECISION DEFAULT NULL, IN name TEXT DEFAULT NULL, IN value DOUBLE PRECISION DEFAULT NULL, IN created_date TIMESTAMP DEFAULT NULL)
RETURNS schema_sample.sct_0016_dynamic_bulk_collect$t_record
AS
$BODY$
SELECT
    ROW (id, name, value, created_date)::schema_sample.sct_0016_dynamic_bulk_collect$t_record;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0019_process_orders$t_order_rec(IN product_id DOUBLE PRECISION DEFAULT NULL, IN order_quantity DOUBLE PRECISION DEFAULT NULL)
RETURNS schema_sample.sct_0019_process_orders$t_order_rec
AS
$BODY$
SELECT
    ROW (product_id, order_quantity)::schema_sample.sct_0019_process_orders$t_order_rec;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0036_create_binary_id(IN p_prefix TEXT, IN p_id DOUBLE PRECISION, IN p_suffix TEXT)
RETURNS BYTEA
AS
$BODY$
DECLARE
    v_prefix_raw BYTEA;
    v_id_raw BYTEA;
    v_suffix_raw BYTEA;
    v_result BYTEA;
BEGIN
/* 各部分をRAWに変換 */
    v_prefix_raw := ENCODE(p_prefix::BYTEA, 'hex');
    v_id_raw := ENCODE(aws_oracle_ext.TO_CHAR(p_id, '0000000')::BYTEA, 'hex');
    v_suffix_raw := ENCODE(p_suffix::BYTEA, 'hex');
    /* 各部分を連結 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    v_result := aws_oracle_ext.utl_raw$concat(r1 => v_prefix_raw, r2 => v_id_raw, r3 => v_suffix_raw);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    RETURN v_result;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0036_fetch_web_content(IN p_url TEXT)
RETURNS TEXT
AS
$BODY$
DECLARE
    /*
    [5340 - Severity CRITICAL - PostgreSQL doesn't support the UTL_HTTP.REQ function. Revise your code to use another function or create a user-defined function.]
    v_request UTL_HTTP.REQ
    */
    /*
    [5340 - Severity CRITICAL - PostgreSQL doesn't support the UTL_HTTP.RESP function. Revise your code to use another function or create a user-defined function.]
    v_response UTL_HTTP.RESP
    */
    v_buffer CHARACTER VARYING(32767);
    v_content TEXT;
BEGIN
/* Oracle固有のUTL_HTTPパッケージを使用 */
    CALL aws_oracle_ext.dbms_lob$createtemporary(lob_loc => v_content);
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    v_request := aws_oracle_ext.UTL_HTTP_BEGIN_REQUEST(p_url);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    v_response := aws_oracle_ext.UTL_HTTP_GET_RESPONSE(v_request);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    BEGIN
        LOOP
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            SELECT aws_oracle_ext.UTL_HTTP_READ_TEXT((v_response).response, v_buffer);
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            CALL aws_oracle_ext.dbms_lob$append(dest_lob => v_content, src_lob => v_buffer);
        END LOOP;
    /*
    [5561 - Severity CRITICAL - PostgreSQL doesn't support the END_OF_BODY exception. Revise your code to use another type of exception and try again.]
    WHEN UTL_HTTP.END_OF_BODY THEN
                UTL_HTTP.END_RESPONSE(v_response);
    */
    /*
    [5580 - Severity CRITICAL - The exception block in the converted code is empty. Review the converted code and convert your source code manually where necessary.]
    EXCEPTION
           WHEN UTL_HTTP.END_OF_BODY THEN
               UTL_HTTP.END_RESPONSE(v_response);
    */
    END;
    RETURN v_content;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0036_get_employee_hierarchy(IN p_emp_id DOUBLE PRECISION)
RETURNS REFCURSOR
AS
$BODY$
DECLARE
    v_result REFCURSOR;
    v_result$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
BEGIN
/* Oracle固有のCONNECT BY句を使用した階層クエリ */
    v_result := NULL;
    OPEN v_result FOR
    WITH RECURSIVE t (employee_id, employee_name, manager_id, hierarchy_level, sibl_employee_name)
    AS (SELECT
        employee_id, employee_name, manager_id, (1)::NUMERIC AS hierarchy_level, ARRAY[employee_name] AS sibl_employee_name
        FROM schema_sample.t_0036_employees
        WHERE employee_id = p_emp_id
    UNION ALL
    SELECT
        t_2.employee_id, t_2.employee_name, t_2.manager_id, (t.hierarchy_level + 1)::NUMERIC AS hierarchy_level, (t.sibl_employee_name || t_2.employee_name)::CHARACTER VARYING(100)[]
        FROM schema_sample.t_0036_employees AS t_2, t
        WHERE t.employee_id = t_2.manager_id)
    SELECT
        employee_id, employee_name, manager_id, hierarchy_level
        FROM t
        ORDER BY t.sibl_employee_name;
    v_result$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    RETURN v_result;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0036_get_file_content(IN p_directory TEXT, IN p_filename TEXT)
RETURNS TEXT
AS
$BODY$
DECLARE
    v_file CHARACTER VARYING(255);
    v_dest TEXT;
    v_dest_offset NUMERIC(38) := 1;
    v_src_offset NUMERIC(38) := 1;
    v_lang_context NUMERIC(38) := aws_oracle_ext.dbms_lob$default_lang_ctx();
    v_warning NUMERIC(38);
BEGIN
/* Oracle固有のDBMS_LOBパッケージを使用 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    v_file := aws_oracle_ext.bfilename(directory => p_directory, filename => p_filename);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT aws_oracle_ext.dbms_lob$fileopen(v_file, aws_oracle_ext.dbms_lob$file_readonly());
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    CALL aws_oracle_ext.dbms_lob$createtemporary(lob_loc => v_dest);
    /*
    [5340 - Severity CRITICAL - PostgreSQL doesn't support the SYS.DBMS_LOB.GETLENGTH(BFILE) function. Revise your code to use another function or create a user-defined function., 5340 - Severity CRITICAL - PostgreSQL doesn't support the SYS.DBMS_LOB.LOADCLOBFROMFILE(CLOB,BFILE,INTEGER,INTEGER,INTEGER,NUMBER,INTEGER,INTEGER) function. Revise your code to use another function or create a user-defined function.]
    DBMS_LOB.LOADCLOBFROMFILE(
            dest_lob     => v_dest,
            src_bfile    => v_file,
            amount       => DBMS_LOB.GETLENGTH(v_file),
            dest_offset  => v_dest_offset,
            src_offset   => v_src_offset,
            bfile_csid   => DBMS_LOB.DEFAULT_CSID,
            lang_context => v_lang_context,
            warning      => v_warning
        )
    */
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT aws_oracle_ext.dbms_lob_fileclose(v_file);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    RETURN v_dest;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0036_get_remote_data(IN p_id DOUBLE PRECISION)
RETURNS TEXT
AS
$BODY$
DECLARE
    v_result CHARACTER VARYING(1000);
BEGIN
/* Oracle固有のデータベースリンク構文を使用 */
    SELECT
        data_value
        INTO STRICT v_result
        FROM SCT_0036_remote_table@SCT_0036_remote_db_link
        WHERE id = p_id;
    RETURN v_result;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN NULL;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0036_get_session_info()
RETURNS TEXT
AS
$BODY$
DECLARE
    v_info CHARACTER VARYING(4000);
BEGIN
/* Oracle固有のSYS_CONTEXT関数を使用 */
    v_info := CONCAT_WS('', 'User: ', aws_oracle_ext.SYS_CONTEXT('USERENV', 'SESSION_USER'), ', IP: ', aws_oracle_ext.SYS_CONTEXT('USERENV', 'IP_ADDRESS'), ', Terminal: ', aws_oracle_ext.SYS_CONTEXT('USERENV', 'TERMINAL'), ', DB Name: ', aws_oracle_ext.SYS_CONTEXT('USERENV', 'DB_NAME'));
    RETURN v_info;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0037_update_with_commit(IN p_id DOUBLE PRECISION, IN p_new_value DOUBLE PRECISION)
RETURNS DOUBLE PRECISION
AS
$BODY$
DECLARE
    v_result DOUBLE PRECISION := 0;
    error_transaction$returned_sqlstate TEXT;
    error_transaction$message_text TEXT;
    error_transaction$pg_exception_context TEXT;
BEGIN
/* トランザクションに名前を設定 */
    /* 更新処理 */
    UPDATE schema_sample.t_0037
    SET value = p_new_value, update_date = (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
        WHERE id = p_id;
    /* 影響を受けた行数を取得 */
    GET DIAGNOSTICS v_result = ROW_COUNT;
    /* 明示的にコミット */
    RETURN v_result;
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_transaction$returned_sqlstate = RETURNED_SQLSTATE,
                error_transaction$message_text = MESSAGE_TEXT,
                error_transaction$pg_exception_context = PG_EXCEPTION_CONTEXT;
            RAISE NOTICE '% % %', error_transaction$returned_sqlstate, error_transaction$message_text || chr(10), error_transaction$pg_exception_context;
            RETURN NULL;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0054_get_greeting()
RETURNS TEXT
AS
$BODY$
BEGIN
    RAISE EXCEPTION USING message = format('Java class method missed: %s', 'SCT_0054_JavaProc.getGreeting() return java.lang.String');
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0054_get_table_name(IN p_id DOUBLE PRECISION)
RETURNS TEXT
AS
$BODY$
BEGIN
    RAISE EXCEPTION USING message = format('Java class method missed: %s', 'SCT_0054_JavaProc.getTableName(int) return java.lang.String');
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0054_get_table_value(IN p_id DOUBLE PRECISION)
RETURNS DOUBLE PRECISION
AS
$BODY$
BEGIN
    RAISE EXCEPTION USING message = format('Java class method missed: %s', 'SCT_0054_JavaProc.getTableValue(int) return double');
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0054_insert_data(IN p_id DOUBLE PRECISION, IN p_name TEXT, IN p_value DOUBLE PRECISION)
RETURNS DOUBLE PRECISION
AS
$BODY$
BEGIN
    RAISE EXCEPTION USING message = format('Java class method missed: %s', 'SCT_0054_JavaProc.insertData(int, java.lang.String, double) return int');
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0062_data_obj_type(IN id DOUBLE PRECISION DEFAULT NULL, IN value CHARACTER VARYING DEFAULT NULL, IN calc_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL)
RETURNS schema_sample.sct_0062_data_obj_type
AS
$BODY$
SELECT ROW(id,value,calc_date)::schema_sample.sct_0062_data_obj_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0062_generate_data(IN p_rows DOUBLE PRECISION DEFAULT 10, IN p_prefix TEXT DEFAULT 'Value-')
RETURNS SETOF schema_sample.sct_0062_data_tab_type
AS
$BODY$
DECLARE
    v_id DOUBLE PRECISION;
    v_value CHARACTER VARYING(100);
    v_date TIMESTAMP(0) WITHOUT TIME ZONE;
BEGIN
/* 指定された行数分のデータを生成 */
    FOR i IN 1..p_rows LOOP
        /* DUAL テーブルを使用してデータを生成 */
        SELECT
            i, CONCAT_WS('', p_prefix, aws_oracle_ext.TO_CHAR(i, 'FM000')), (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) + (i / 24::NUMERIC || ' days')::INTERVAL
            /* 1時間ずつ増加 */
            INTO STRICT v_id, v_value, v_date;
        /* 生成したデータを行としてパイプライン */
        RETURN NEXT ARRAY[schema_sample.sct_0062_data_obj_type(v_id, v_value, v_date)];
    END LOOP;
    RETURN;
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RETURN;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0071_cursor_sync_issue_demo$init()
RETURNS void
AS
$BODY$
BEGIN
    IF aws_oracle_ext.packageinitialize(proutinename => 'schema_sample.sct_0071_cursor_sync_issue_demo')
    THEN
        perform aws_oracle_ext.set_package_variable_record(proutinename => 'schema_sample.sct_0071_cursor_sync_issue_demo', pvariable => 'v_main_rec', pval => NULL::schema_sample.sct_0071_cursor_sync_issue_demo$main_cursor);
    ELSE
        RETURN;
    END IF;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0071_cursor_sync_issue_demo$main_cursor$31468eb8()
RETURNS void
AS
$BODY$
DECLARE schema_sample$sct_0071_cursor_sync_issue_demo$main_cursor CURSOR WITH HOLD FOR
WITH RECURSIVE t (data)
AS (SELECT
        CONCAT_WS('', 'MAIN_', (1)::NUMERIC) AS data, (1)::NUMERIC AS level
UNION ALL
SELECT CONCAT_WS('', 'MAIN_', (t.level + 1)::NUMERIC) AS data, (t.level + 1)::NUMERIC AS level
    FROM t
    WHERE (t.level + 1)::NUMERIC <= 3)
SELECT
    data
    FROM t;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0072_pkg$get_item_count()
RETURNS DOUBLE PRECISION
AS
$BODY$
DECLARE
    v_count DOUBLE PRECISION;
BEGIN
    SELECT
        COUNT(*)
        INTO STRICT v_count
        FROM schema_sample.t_0072;
    RETURN v_count;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.t_0024_person_type(IN person_id DOUBLE PRECISION DEFAULT NULL, IN first_name CHARACTER VARYING DEFAULT NULL, IN last_name CHARACTER VARYING DEFAULT NULL, IN birth_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, IN phone_number CHARACTER VARYING DEFAULT NULL, IN email CHARACTER VARYING DEFAULT NULL)
RETURNS schema_sample.t_0024_person_type
AS
$BODY$
SELECT ROW(person_id,first_name,last_name,birth_date,phone_number,email)::schema_sample.t_0024_person_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.t_0033_address_type(IN street CHARACTER VARYING DEFAULT NULL, IN city CHARACTER VARYING DEFAULT NULL, IN state CHARACTER VARYING DEFAULT NULL, IN postal_code CHARACTER VARYING DEFAULT NULL)
RETURNS schema_sample.t_0033_address_type
AS
$BODY$
SELECT ROW(street,city,state,postal_code)::schema_sample.t_0033_address_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.t_0033_phone_type(IN phone_type CHARACTER VARYING DEFAULT NULL, IN phone_number CHARACTER VARYING DEFAULT NULL)
RETURNS schema_sample.t_0033_phone_type
AS
$BODY$
SELECT ROW(phone_type,phone_number)::schema_sample.t_0033_phone_type;
$BODY$
LANGUAGE  sql;

CREATE OR REPLACE FUNCTION schema_sample.f_trigger_vc$t_0040()
RETURNS trigger
AS
$BODY$
BEGIN
    NEW.product_summary := CONCAT_WS('', NEW.product_name, ' - ', aws_oracle_ext.TO_CHAR(NEW.unit_price, '9,999,999.99'), '円 x ', aws_oracle_ext.TO_CHAR(NEW.quantity), '個');
    RETURN NEW;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0035_trigger$t_0035()
RETURNS trigger
AS
$BODY$
BEGIN
/* INSERTの場合 */
    IF TG_OP = 'INSERT' THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'レコードが挿入されました。ID: ', new.id));
    /* UPDATEの場合 */
    ELSIF TG_OP = 'UPDATE' THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'レコードが更新されました。ID: ', new.id));
    /* DELETEの場合 */
    ELSIF TG_OP = 'DELETE' THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'レコードが削除されました。ID: ', old.id));
    END IF;

    IF TG_OP = 'INSERT' THEN
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.sct_0041_column_update_trigger$t_0041()
RETURNS trigger
AS
$BODY$
BEGIN
/* ID列が更新された場合 */
    BEGIN
    /*
    [5556 - Severity CRITICAL - PostgreSQL doesn't support conditional predicates. Revise your code to use simple indexes and try again.]
    IF UPDATING('ID') THEN
            INSERT INTO T_0041_AUDIT (
                AUDIT_ID,
                TABLE_NAME,
                OPERATION,
                COLUMN_NAME,
                RECORD_ID,
                OLD_VALUE,
                NEW_VALUE,
                CHANGED_BY,
                CHANGE_DATE
            ) VALUES (
                T_0041_AUDIT_SEQ.NEXTVAL,
                'T_0041',
                'UPDATE',
                'ID',
                :NEW.ID,
                TO_CHAR(:OLD.ID),
                TO_CHAR(:NEW.ID),
                USER,
                SYSDATE
            );
        END IF
    */
    /* NAME列が更新された場合 */
    
    /*
    [5556 - Severity CRITICAL - PostgreSQL doesn't support conditional predicates. Revise your code to use simple indexes and try again.]
    IF UPDATING('NAME') THEN
            INSERT INTO T_0041_AUDIT (
                AUDIT_ID,
                TABLE_NAME,
                OPERATION,
                COLUMN_NAME,
                RECORD_ID,
                OLD_VALUE,
                NEW_VALUE,
                CHANGED_BY,
                CHANGE_DATE
            ) VALUES (
                T_0041_AUDIT_SEQ.NEXTVAL,
                'T_0041',
                'UPDATE',
                'NAME',
                :NEW.ID,
                :OLD.NAME,
                :NEW.NAME,
                USER,
                SYSDATE
            );
        END IF
    */
    /* STATUS列が更新された場合 */
    
    /*
    [5556 - Severity CRITICAL - PostgreSQL doesn't support conditional predicates. Revise your code to use simple indexes and try again.]
    IF UPDATING('STATUS') THEN
            INSERT INTO T_0041_AUDIT (
                AUDIT_ID,
                TABLE_NAME,
                OPERATION,
                COLUMN_NAME,
                RECORD_ID,
                OLD_VALUE,
                NEW_VALUE,
                CHANGED_BY,
                CHANGE_DATE
            ) VALUES (
                T_0041_AUDIT_SEQ.NEXTVAL,
                'T_0041',
                'UPDATE',
                'STATUS',
                :NEW.ID,
                :OLD.STATUS,
                :NEW.STATUS,
                USER,
                SYSDATE
            );
        END IF
    */
    /* VALUE列が更新された場合 */
    
    /*
    [5556 - Severity CRITICAL - PostgreSQL doesn't support conditional predicates. Revise your code to use simple indexes and try again.]
    IF UPDATING('VALUE') THEN
            INSERT INTO T_0041_AUDIT (
                AUDIT_ID,
                TABLE_NAME,
                OPERATION,
                COLUMN_NAME,
                RECORD_ID,
                OLD_VALUE,
                NEW_VALUE,
                CHANGED_BY,
                CHANGE_DATE
            ) VALUES (
                T_0041_AUDIT_SEQ.NEXTVAL,
                'T_0041',
                'UPDATE',
                'VALUE',
                :NEW.ID,
                TO_CHAR(:OLD.VALUE),
                TO_CHAR(:NEW.VALUE),
                USER,
                SYSDATE
            );
        END IF
    */
    END;
    RETURN NEW;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.t_0031_trigger$t_0031()
RETURNS trigger
AS
$BODY$
BEGIN
/* 値が変更された場合のみログを記録 */
    IF old.value != new.value THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => '値が変更されました:');
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', old.id));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '旧値: ', old.value));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '新値: ', new.value));
        /* ステータスも更新 */

        IF new.value > old.value THEN
            new.status := 'INCREASED';
        ELSE
            new.status := 'DECREASED';
        END IF;
        /* 最終更新日時を設定 */
        new.last_updated := (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0);
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE  plpgsql;

CREATE OR REPLACE FUNCTION schema_sample.t_0032_usert_0032_trigger$t_0032()
RETURNS trigger
AS
$BODY$
BEGIN
/* INSERTの場合 */
    IF TG_OP = 'INSERT' THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'INSERT操作が実行されました。ID: ', new.id, ', NAME: ', new.name));
    /* UPDATEの場合 */
    ELSIF TG_OP = 'UPDATE' THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => 'UPDATE操作が実行されました。');
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  変更前 - ID: ', old.id, ', NAME: ', old.name, ', VALUE: ', old.value));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  変更後 - ID: ', new.id, ', NAME: ', new.name, ', VALUE: ', new.value));
    /* DELETEの場合 */
    ELSIF TG_OP = 'DELETE' THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'DELETE操作が実行されました。ID: ', old.id, ', NAME: ', old.name));
    END IF;

    IF TG_OP = 'INSERT' THEN
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
END;
$BODY$
LANGUAGE  plpgsql;

-- ------------ Write CREATE-PROCEDURE-stage scripts -----------

CREATE OR REPLACE PROCEDURE schema_sample.sct_0001_calculate_time_difference(IN p_start_date TIMESTAMP WITHOUT TIME ZONE, IN p_end_date TIMESTAMP WITHOUT TIME ZONE)
AS 
$BODY$
DECLARE
    v_interval INTERVAL DAY TO SECOND;
/* この特定のINTERVAL型の使用方法がPostgreSQLと互換性がない場合がある */
BEGIN
    v_interval := p_end_date - p_start_date;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Time difference: ', v_interval));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0001_combined_types_example(IN p_row_id TEXT, IN p_name TEXT, IN p_type_code CHARACTER, IN p_dec DOUBLE PRECISION, IN p_any JSONB)
AS 
$BODY$
DECLARE
    v_result CHARACTER VARYING(500);
    v_type_desc CHARACTER(20);
BEGIN
/* 型コードに基づいて説明を設定 */
    CASE p_type_code
        WHEN 'A' THEN
            v_type_desc := 'Type A            ';
        WHEN 'B' THEN
            v_type_desc := 'Type B            ';
        ELSE
            v_type_desc := 'Unknown           ';
    END CASE;
    /* 結果の組み立て */
    v_result := CONCAT_WS('', 'ID: ', p_row_id, ', Name: ', p_name, ', Type: ', v_type_desc);
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '処理結果: ', v_result));
    EXCEPTION
        WHEN others THEN
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0001_process_file_data(IN p_directory TEXT, IN p_filename TEXT)
AS 
$BODY$
DECLARE
    v_file CHARACTER VARYING(255);
    /* BFILE型はPostgreSQLに直接対応するものがない */
    v_content BYTEA;
BEGIN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    v_file := aws_oracle_ext.bfilename(directory => p_directory, filename => p_filename);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT aws_oracle_ext.dbms_lob$fileopen(v_file, aws_oracle_ext.dbms_lob$file_readonly());
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* ファイル処理ロジック */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT aws_oracle_ext.dbms_lob_fileclose(v_file);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0001_process_nested_table()
AS 
$BODY$
DECLARE
    /* ネストテーブル型 */
    v_items schema_sample.sct_0001_process_nested_table$item_list_type;
BEGIN
    v_items := ARRAY['Item1', 'Item2', 'Item3']::schema_sample.sct_0001_process_nested_table$item_list_type;

    FOR i IN 1..COALESCE(array_length(v_items, 1), 0) LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Item ', i, ': ', (v_items)[i]));
    END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0001_process_xml_data(IN p_xml_data XML)
AS 
$BODY$
/* XMLTypeの特定の使用方法がPostgreSQLと互換性がない場合がある */
DECLARE
    v_value CHARACTER VARYING(100);
BEGIN
    SELECT
        (xpath('//self::text()', (xpath('/root/element', p_xml_data))[1]))[1]::TEXT
        INTO STRICT v_value;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Extracted value: ', v_value));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0001_update_by_rowid(IN p_table_name TEXT, IN p_row_id CHARACTER, IN p_new_value TEXT)
AS 
$BODY$
/* ROWID型はPostgreSQLに直接対応するものがない */
DECLARE
    v_sql CHARACTER VARYING(1000);
BEGIN
    v_sql := CONCAT_WS('', 'UPDATE ', p_table_name, ' SET some_column = :1 WHERE ROWID = :2');
    /*
    [5340 - Severity CRITICAL - PostgreSQL doesn't support the STANDARD.ROWID function. Revise your code to use another function or create a user-defined function.]
    EXECUTE IMMEDIATE v_sql USING p_new_value, p_row_id
    */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0002_dynamic_cursor_operations(IN p_table_name TEXT)
AS 
$BODY$
DECLARE
    aws_oracle_ext$array_id$temporary BIGINT;
    v_cursor REFCURSOR;
    v_cursor$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    v_cursor_array VARCHAR(100) := 'v_cursor_array';
    v_cursor_id NUMERIC(38);
    v_dummy CHARACTER VARYING(1000);
    v_column_count NUMERIC(38);
    v_desc_tab VARCHAR(100) := 'v_desc_tab';
BEGIN
/* 動的SQLでカーソルを開く */
    aws_oracle_ext$array_id$temporary := aws_oracle_ext.array$create_array(p_array_name => 'v_cursor_array', p_procedure_name => 'schema_sample.sct_0002_dynamic_cursor_operations');
    PERFORM aws_oracle_ext.array$add_fields_to_array(p_array_id => aws_oracle_ext$array_id$temporary, p_fields => '[{"":"CHARACTER VARYING(4000)"}]');
    PERFORM aws_oracle_ext.array$create_storage_table(p_array_name => 'v_cursor_array', p_procedure_name => 'schema_sample.sct_0002_dynamic_cursor_operations', p_cast_type_name => 'varchar2_table.dbms_sql$varchar2_table$c', pWithData => FALSE);
    aws_oracle_ext$array_id$temporary := aws_oracle_ext.array$create_array(p_array_name => 'v_desc_tab', p_procedure_name => 'schema_sample.sct_0002_dynamic_cursor_operations');
    PERFORM aws_oracle_ext.array$add_fields_to_array(p_array_id => aws_oracle_ext$array_id$temporary, p_fields => '[{"col_type":"INTEGER"},{"col_max_len":"INTEGER"},{"col_name":"CHARACTER VARYING(32)"},{"col_name_len":"INTEGER"},{"col_schema_name":"CHARACTER VARYING(32)"},{"col_schema_name_len":"INTEGER"},{"col_precision":"INTEGER"},{"col_scale":"INTEGER"},{"col_charsetid":"INTEGER"},{"col_charsetform":"INTEGER"},{"col_null_ok":"BOOLEAN"}]');
    PERFORM aws_oracle_ext.array$create_storage_table(p_array_name => 'v_desc_tab', p_procedure_name => 'schema_sample.sct_0002_dynamic_cursor_operations', p_cast_type_name => 'desc_tab.dbms_sql$desc_tab', pWithData => FALSE);
    v_cursor := NULL;
    OPEN v_cursor FOR
    EXECUTE CONCAT_WS('', 'SELECT * FROM  ', p_table_name);
    v_cursor$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    /* REF CURSORをDBMS_SQL.PARSE用に変換 */
    v_cursor_id := aws_oracle_ext.dbms_sql$to_cursor_number(v_cursor::REFCURSOR);
    /* カラム情報を取得 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    PERFORM aws_oracle_ext.dbms_sql$describe_columns((v_cursor_id)::INTEGER, v_column_count, v_desc_tab);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* 各カラムを定義 */
    FOR i IN 1..v_column_count LOOP
        PERFORM aws_oracle_ext.dbms_sql$define_column((v_cursor_id)::INTEGER, (i)::INTEGER, v_dummy, (1000)::INTEGER);
    END LOOP;
    /* 結果を処理 */

    WHILE aws_oracle_ext.dbms_sql$fetch_rows((v_cursor_id)::INTEGER) > 0 LOOP
        FOR i IN 1..v_column_count LOOP
            SELECT
                p_column_val
                INTO v_cursor_array
                FROM aws_oracle_ext.dbms_sql$column_value((v_cursor_id)::INTEGER, (i)::INTEGER, (aws_oracle_ext.array$get_value(p_array_value_path => 'v_cursor_array[' || i || ']', p_procedure_name => 'schema_sample.sct_0002_dynamic_cursor_operations', p_value_datatype => NULL::varchar2_table.dbms_sql$varchar2_table$c)).column_value);
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Column ', i, ': ', (aws_oracle_ext.array$get_value(p_array_value_path => 'v_cursor_array[' || i || ']', p_procedure_name => 'schema_sample.sct_0002_dynamic_cursor_operations', p_value_datatype => NULL::varchar2_table.dbms_sql$varchar2_table$c)).column_value));
        END LOOP;
    END LOOP;
    v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
    PERFORM aws_oracle_ext.array$clear_procedure('schema_sample.sct_0002_dynamic_cursor_operations');
    EXCEPTION
        WHEN others THEN
            IF aws_oracle_ext.dbms_sql$is_open((v_cursor_id)::INTEGER) THEN
                v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
            END IF;
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0002_process_any_data(IN p_data JSONB)
AS 
$BODY$
DECLARE
    v_type_name CHARACTER VARYING(100);
    v_result DOUBLE PRECISION;
    v_number DOUBLE PRECISION;
    v_varchar CHARACTER VARYING(4000);
    v_date TIMESTAMP(0) WITHOUT TIME ZONE;
BEGIN
    v_type_name := aws_oracle_ext.sys_anydata$getTypeName(p_data);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Data type: ', v_type_name));

    IF v_type_name = 'SYS.NUMBER' THEN
        /*
        [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported SYS.ANYDATA.GETNUMBER(ANYDATA,NUMBER) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
        v_result := p_data.GETNUMBER(v_number)
        */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Number value: ', v_number));
    ELSIF v_type_name = 'SYS.VARCHAR2' THEN
        /*
        [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported SYS.ANYDATA.GETVARCHAR2(ANYDATA,VARCHAR2) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
        v_result := p_data.GETVARCHAR2(v_varchar)
        */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'String value: ', v_varchar));
    ELSIF v_type_name = 'SYS.DATE' THEN
        /*
        [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported SYS.ANYDATA.GETDATE(ANYDATA,DATE) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
        v_result := p_data.GETDATE(v_date)
        */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Date value: ', aws_oracle_ext.TO_CHAR(v_date, 'YYYY-MM-DD')));
    ELSE
        CALL aws_oracle_ext.dbms_output$put_line(a => 'Unsupported type');
    END IF;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0002_process_matrix(IN p_matrix schema_sample.sct_0002_matrix_type)
AS 
$BODY$
DECLARE
    v_sum DOUBLE PRECISION := 0;
BEGIN
/* 2次元配列の処理 */
    FOR i IN 1..COALESCE(array_length(p_matrix, 1), 0) LOOP
        FOR j IN 1..COALESCE(array_length((p_matrix)[i], 1), 0) LOOP
            v_sum := (v_sum + ((p_matrix)[i])[j])::NUMERIC;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Matrix[', i, ',', j, '] = ', ((p_matrix)[i])[j]));
        END LOOP;
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Matrix sum: ', v_sum));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0002_process_order(IN p_order schema_sample.sct_0002_order_type)
AS 
$BODY$
BEGIN
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported SCHEMA_SAMPLE.SCT_0002_ORDER_TYPE.GET_TOTAL_PRICE() data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    DBMS_OUTPUT.PUT_LINE('Order total: ' || p_order.get_total_price())
    */
    /* ネストされたコレクションの処理 */
    FOR i IN 1..COALESCE(array_length((p_order).items, 1), 0) LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'Item ', i, ': ', (((p_order).items)[i]).item_name));
    END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0002_process_person(IN p_person schema_sample.sct_0002_person_type)
AS 
$BODY$
BEGIN
    BEGIN
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported SCHEMA_SAMPLE.SCT_0002_PERSON_TYPE.GET_FULL_ADDRESS() data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    DBMS_OUTPUT.PUT_LINE(p_person.get_full_address())
    */
    END;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0004_dummy(IN p_param001 TEXT DEFAULT NULL, IN p_param002 TEXT DEFAULT NULL, IN p_param003 TEXT DEFAULT NULL, IN p_param004 TEXT DEFAULT NULL, IN p_param005 TEXT DEFAULT NULL, IN p_param006 TEXT DEFAULT NULL, IN p_param007 TEXT DEFAULT NULL, IN p_param008 TEXT DEFAULT NULL, IN p_param009 TEXT DEFAULT NULL, IN p_param010 TEXT DEFAULT NULL, IN p_param011 TEXT DEFAULT NULL, IN p_param012 TEXT DEFAULT NULL, IN p_param013 TEXT DEFAULT NULL, IN p_param014 TEXT DEFAULT NULL, IN p_param015 TEXT DEFAULT NULL, IN p_param016 TEXT DEFAULT NULL, IN p_param017 TEXT DEFAULT NULL, IN p_param018 TEXT DEFAULT NULL, IN p_param019 TEXT DEFAULT NULL, IN p_param020 TEXT DEFAULT NULL, IN p_param021 TEXT DEFAULT NULL, IN p_param022 TEXT DEFAULT NULL, IN p_param023 TEXT DEFAULT NULL, IN p_param024 TEXT DEFAULT NULL, IN p_param025 TEXT DEFAULT NULL, IN p_param026 TEXT DEFAULT NULL, IN p_param027 TEXT DEFAULT NULL, IN p_param028 TEXT DEFAULT NULL, IN p_param029 TEXT DEFAULT NULL, IN p_param030 TEXT DEFAULT NULL, IN p_param031 TEXT DEFAULT NULL, IN p_param032 TEXT DEFAULT NULL, IN p_param033 TEXT DEFAULT NULL, IN p_param034 TEXT DEFAULT NULL, IN p_param035 TEXT DEFAULT NULL, IN p_param036 TEXT DEFAULT NULL, IN p_param037 TEXT DEFAULT NULL, IN p_param038 TEXT DEFAULT NULL, IN p_param039 TEXT DEFAULT NULL, IN p_param040 TEXT DEFAULT NULL, IN p_param041 TEXT DEFAULT NULL, IN p_param042 TEXT DEFAULT NULL, IN p_param043 TEXT DEFAULT NULL, IN p_param044 TEXT DEFAULT NULL, IN p_param045 TEXT DEFAULT NULL, IN p_param046 TEXT DEFAULT NULL, IN p_param047 TEXT DEFAULT NULL, IN p_param048 TEXT DEFAULT NULL, IN p_param049 TEXT DEFAULT NULL, IN p_param050 TEXT DEFAULT NULL, IN p_param051 TEXT DEFAULT NULL, IN p_param052 TEXT DEFAULT NULL, IN p_param053 TEXT DEFAULT NULL, IN p_param054 TEXT DEFAULT NULL, IN p_param055 TEXT DEFAULT NULL, IN p_param056 TEXT DEFAULT NULL, IN p_param057 TEXT DEFAULT NULL, IN p_param058 TEXT DEFAULT NULL, IN p_param059 TEXT DEFAULT NULL, IN p_param060 TEXT DEFAULT NULL, IN p_param061 TEXT DEFAULT NULL, IN p_param062 TEXT DEFAULT NULL, IN p_param063 TEXT DEFAULT NULL, IN p_param064 TEXT DEFAULT NULL, IN p_param065 TEXT DEFAULT NULL, IN p_param066 TEXT DEFAULT NULL, IN p_param067 TEXT DEFAULT NULL, IN p_param068 TEXT DEFAULT NULL, IN p_param069 TEXT DEFAULT NULL, IN p_param070 TEXT DEFAULT NULL, IN p_param071 TEXT DEFAULT NULL, IN p_param072 TEXT DEFAULT NULL, IN p_param073 TEXT DEFAULT NULL, IN p_param074 TEXT DEFAULT NULL, IN p_param075 TEXT DEFAULT NULL, IN p_param076 TEXT DEFAULT NULL, IN p_param077 TEXT DEFAULT NULL, IN p_param078 TEXT DEFAULT NULL, IN p_param079 TEXT DEFAULT NULL, IN p_param080 TEXT DEFAULT NULL, IN p_param081 TEXT DEFAULT NULL, IN p_param082 TEXT DEFAULT NULL, IN p_param083 TEXT DEFAULT NULL, IN p_param084 TEXT DEFAULT NULL, IN p_param085 TEXT DEFAULT NULL, IN p_param086 TEXT DEFAULT NULL, IN p_param087 TEXT DEFAULT NULL, IN p_param088 TEXT DEFAULT NULL, IN p_param089 TEXT DEFAULT NULL, IN p_param090 TEXT DEFAULT NULL, IN p_param091 TEXT DEFAULT NULL, IN p_param092 TEXT DEFAULT NULL, IN p_param093 TEXT DEFAULT NULL, IN p_param094 TEXT DEFAULT NULL, IN p_param095 TEXT DEFAULT NULL, IN p_param096 TEXT DEFAULT NULL, IN p_param097 TEXT DEFAULT NULL, IN p_param098 TEXT DEFAULT NULL, IN p_param099 TEXT DEFAULT NULL, IN p_param100 TEXT DEFAULT NULL, IN p_param101 TEXT DEFAULT NULL, IN p_param102 TEXT DEFAULT NULL, IN p_param103 TEXT DEFAULT NULL, IN p_param104 TEXT DEFAULT NULL, IN p_param105 TEXT DEFAULT NULL, IN p_param106 TEXT DEFAULT NULL, IN p_param107 TEXT DEFAULT NULL, IN p_param108 TEXT DEFAULT NULL, IN p_param109 TEXT DEFAULT NULL, IN p_param110 TEXT DEFAULT NULL, IN p_param111 TEXT DEFAULT NULL, IN p_param112 TEXT DEFAULT NULL, IN p_param113 TEXT DEFAULT NULL, IN p_param114 TEXT DEFAULT NULL, IN p_param115 TEXT DEFAULT NULL, IN p_param116 TEXT DEFAULT NULL, IN p_param117 TEXT DEFAULT NULL, IN p_param118 TEXT DEFAULT NULL, IN p_param119 TEXT DEFAULT NULL, IN p_param120 TEXT DEFAULT NULL, IN p_param121 TEXT DEFAULT NULL, IN p_param122 TEXT DEFAULT NULL, IN p_param123 TEXT DEFAULT NULL, IN p_param124 TEXT DEFAULT NULL, IN p_param125 TEXT DEFAULT NULL, IN p_param126 TEXT DEFAULT NULL, IN p_param127 TEXT DEFAULT NULL, IN p_param128 TEXT DEFAULT NULL, IN p_param129 TEXT DEFAULT NULL, IN p_param130 TEXT DEFAULT NULL, IN p_param131 TEXT DEFAULT NULL, IN p_param132 TEXT DEFAULT NULL, IN p_param133 TEXT DEFAULT NULL, IN p_param134 TEXT DEFAULT NULL, IN p_param135 TEXT DEFAULT NULL, IN p_param136 TEXT DEFAULT NULL, IN p_param137 TEXT DEFAULT NULL, IN p_param138 TEXT DEFAULT NULL, IN p_param139 TEXT DEFAULT NULL, IN p_param140 TEXT DEFAULT NULL, IN p_param141 TEXT DEFAULT NULL, IN p_param142 TEXT DEFAULT NULL, IN p_param143 TEXT DEFAULT NULL, IN p_param144 TEXT DEFAULT NULL, IN p_param145 TEXT DEFAULT NULL, IN p_param146 TEXT DEFAULT NULL, IN p_param147 TEXT DEFAULT NULL, IN p_param148 TEXT DEFAULT NULL, IN p_param149 TEXT DEFAULT NULL, IN p_param150 TEXT DEFAULT NULL)
AS 
$BODY$
BEGIN
/* 何も実施しないプロシージャ */
    NULL;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0005_call_commit()
AS 
$BODY$
BEGIN
    CALL schema_sample.sct_0005_commit(1);
    COMMIT;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0005_commit(IN p_id DOUBLE PRECISION)
AS 
$BODY$
BEGIN
    INSERT INTO schema_sample.t_0005
    VALUES (p_id);
    COMMIT;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0007_insert_record(IN p_id DOUBLE PRECISION, IN p_name TEXT, IN p_value DOUBLE PRECISION)
AS 
$BODY$
BEGIN
/* 入力値の検証 */
    IF p_id IS NULL THEN
        RAISE USING hint = -20001, message = 'IDを指定してください。', detail = 'User-defined exception';
    END IF;

    IF p_name IS NULL OR LENGTH(TRIM(p_name)) = 0 THEN
        RAISE USING hint = -20002, message = '名前を指定してください。', detail = 'User-defined exception';
    END IF;

    IF p_value IS NULL THEN
        RAISE USING hint = -20003, message = '値を指定してください。', detail = 'User-defined exception';
    END IF;

    IF p_value < 0 THEN
        RAISE USING hint = -20004, message = '値は0以上である必要があります。', detail = 'User-defined exception';
    END IF;
    /* レコードの挿入 */
    INSERT INTO schema_sample.t_0007 (id, name, value, created_date)
    VALUES (p_id, p_name, p_value, (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0));
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'レコードが正常に挿入されました。ID: ', p_id));
    EXCEPTION
        WHEN unique_violation THEN
            RAISE USING hint = -20005, message = CONCAT_WS('', 'ID ', p_id, ' は既に存在します。'), detail = 'User-defined exception';
        WHEN others THEN
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            RAISE USING hint = -20999, message = CONCAT_WS('', 'エラーが発生しました: ', SQLERRM), detail = 'User-defined exception';
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0008_json_array_demo(IN p_id DOUBLE PRECISION, IN p_name TEXT)
AS 
$BODY$
/* JSON配列オブジェクトを宣言 */
DECLARE
    v_json_array VARCHAR(8000);
    v_json_object VARCHAR(8000);
    v_nested_array VARCHAR(8000);
    v_result TEXT;
    /* Oracle固有の型を使用 */
    v_anydata JSONB;
    v_xmltype XML;
    v_interval INTERVAL DAY TO SECOND;
    /* フィールド値の割り当てを複雑にする変数 */
    v_record schema_sample.sct_0008_json_array_demo$t_rec := schema_sample.sct_0008_json_array_demo$t_rec();
BEGIN
/* 新しいJSON配列を作成 */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.{__PUBLIC}.JSON_ARRAY_T data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_array := JSON_ARRAY_T()
    */
    /* 配列に要素を追加 */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.APPEND(JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_array.append('値1')
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.APPEND(JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_array.append(123)
    */
    /* JSONオブジェクトを作成 */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.{__PUBLIC}.JSON_OBJECT_T data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_object := JSON_OBJECT_T()
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_OBJECT_T.PUT(VARCHAR2,JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_object.put('name', p_name)
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_OBJECT_T.PUT(VARCHAR2,JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_object.put('id', p_id)
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.APPEND(JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_array.append(v_json_object)
    */
    /* 入れ子配列を作成 */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.{__PUBLIC}.JSON_ARRAY_T data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_nested_array := JSON_ARRAY_T()
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.APPEND(JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_nested_array.append('入れ子配列')
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.APPEND(JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_nested_array.append(456)
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.APPEND(JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_nested_array.append(true)
    */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.APPEND(JSON) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_json_array.append(v_nested_array)
    */
    /* Oracle固有の型を使用 */
    v_xmltype := XMLPARSE (DOCUMENT '<root><element>value</element></root>');
    v_interval := '2 day'::INTERVAL;
    v_anydata := aws_oracle_ext.sys_anydata$ConvertVarchar2('テストデータ');
    /* レコード型に値を割り当て */
    v_record := ROW (p_id, v_record.name, v_record.json_data);
    v_record := ROW (v_record.id, p_name, v_record.json_data);
    v_record := ROW (v_record.id, v_record.name, v_json_array);
    /* 複雑なフィールド割り当て */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.GET_SIZE(JSON_ELEMENT_T) data type. DMS SC created a method stub. To replace it, convert your source code manually., 5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.GET_STRING(JSON_ARRAY_T,NUMBER) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_result := CASE
                      WHEN v_json_array.get_size() > 0 THEN
                        v_json_array.get_String(0) || ' - ' || v_xmltype.getClobVal()
                      ELSE
                        'empty'
                    END
    */
    /* Oracle固有の関数を使用 */
    v_result := (CONCAT_WS('', v_result, ' - ', aws_oracle_ext.TO_CHAR(aws_oracle_ext.systimestamp(), 'YYYY-MM-DD"T"HH24:MI:SS.FF TZR'), ' - ', aws_oracle_ext.SYS_CONTEXT('USERENV', 'SESSION_USER')))::TEXT;
    /* JSON配列を文字列に変換 */
    
    /*
    [5030 - Severity CRITICAL - DMS SC can't convert the usage of objects with the unsupported QJD7EPC23VA2VLAFIQBMMKIOY4.SYS.JSON_ARRAY_T.TO_CLOB(JSON_ELEMENT_T) data type. DMS SC created a method stub. To replace it, convert your source code manually.]
    v_result := v_result || ' - ' || v_json_array.to_Clob()
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'JSON配列の内容: ', v_result));
    /* テーブルに保存（複雑な変換を含む） */
    INSERT INTO schema_sample.t_0008 (id, name, json_data)
    VALUES (v_record.id, aws_oracle_ext.substr(CONCAT_WS('', v_record.name, ' - ', aws_oracle_ext.SYS_CONTEXT('USERENV', 'DB_NAME')), 1, 100), v_result);
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'JSONデータがテーブルに保存されました。');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0009_update_tablename_as_subquery()
AS 
$BODY$
BEGIN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    UPDATE schema_sample.t_0009 SET id = 1;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0010_delete_tablename_as_subquery()
AS 
$BODY$
BEGIN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    DELETE FROM schema_sample.t_0010
        WHERE id = 1;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0011_get_employee_info(IN p_id DOUBLE PRECISION, OUT p_name TEXT, OUT p_value DOUBLE PRECISION)
AS 
$BODY$
BEGIN
/* テーブルからデータを取得 */
    SELECT
        name, value
        INTO STRICT p_name, p_value
        FROM schema_sample.t_0011
        WHERE id = p_id;
    /* 例外処理 */
    EXCEPTION
        WHEN no_data_found THEN
            p_name := NULL;
            p_value := NULL;
        WHEN others THEN
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0012_hierarchy_query(IN p_root_id DOUBLE PRECISION DEFAULT 1)
AS 
$BODY$
/* 階層クエリを使用したカーソル */
DECLARE
    c_hierarchy CURSOR FOR
    WITH RECURSIVE t (employee_id, employee_name, manager_id, job_title, hierarchy_level, tree_display, root_employee, path, is_leaf, sibl_employee_name)
    AS (SELECT
        employee_id, employee_name, manager_id, job_title, (1)::NUMERIC AS hierarchy_level, CONCAT_WS('', LPAD(' ', TRUNC((((1)::NUMERIC - 1) * 2)::NUMERIC)::INTEGER), employee_name) AS tree_display, employee_name AS root_employee, employee_name::TEXT AS path, coalesce((SELECT
            0
            FROM schema_sample.t_0012 AS t_3
            WHERE t_3.employee_name = .employee_id
            LIMIT 1), 1) AS is_leaf, ARRAY[employee_name] AS sibl_employee_name
        FROM schema_sample.t_0012
        WHERE employee_id = p_root_id
    UNION ALL
    SELECT
        t_2.employee_id, t_2.employee_name, t_2.manager_id, t_2.job_title, (t.hierarchy_level + 1)::NUMERIC AS hierarchy_level, CONCAT_WS('', LPAD(' ', TRUNC((((t.level + 1)::NUMERIC - 1) * 2)::NUMERIC)::INTEGER), employee_name) AS tree_display, t.root_employee, CONCAT_WS('', t.path, '/', t_2.employee_name::TEXT), coalesce((SELECT
            0
            FROM schema_sample.t_0012 AS t_3
            WHERE t_3.employee_name = t_2.employee_id
            LIMIT 1), 1) AS is_leaf, (t.sibl_employee_name || t_2.employee_name)::CHARACTER VARYING(100)[]
        FROM schema_sample.t_0012 AS t_2, t
        WHERE t.employee_id = t_2.manager_id)
    SELECT
        employee_id, employee_name, manager_id, job_title, hierarchy_level, tree_display, root_employee, path, is_leaf
        FROM t
        ORDER BY t.sibl_employee_name;
    c_hierarchy$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    /* レコード変数 */
    v_emp_rec schema_sample.sct_0012_hierarchy_query$c_hierarchy := ROW (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)::schema_sample.sct_0012_hierarchy_query$c_hierarchy;
    c_hierarchy$FETCH RECORD;
BEGIN
    SELECT
        NULL::DOUBLE PRECISION AS employee_id, NULL::CHARACTER VARYING(100) AS employee_name, NULL::DOUBLE PRECISION AS manager_id, NULL::CHARACTER VARYING(100) AS job_title, NULL::NUMERIC(38) AS level, NULL::VARCHAR(8000) AS tree_display, NULL::CHARACTER VARYING(100) AS root_employee, NULL::VARCHAR(8000) AS path, NULL::NUMERIC(38) AS connect_by_isleaf
        INTO c_hierarchy$FETCH;
    CALL aws_oracle_ext.dbms_output$put_line(a => '組織階層の表示:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '-----------------------------');
    /* カーソルを開いて階層データを取得 */
    c_hierarchy := NULL;
    OPEN c_hierarchy;
    c_hierarchy$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);

    LOOP
        FETCH c_hierarchy INTO c_hierarchy$FETCH.employee_id, c_hierarchy$FETCH.employee_name, c_hierarchy$FETCH.manager_id, c_hierarchy$FETCH.job_title, c_hierarchy$FETCH.level, c_hierarchy$FETCH.tree_display, c_hierarchy$FETCH.root_employee, c_hierarchy$FETCH.path, c_hierarchy$FETCH.connect_by_isleaf;

        IF FOUND THEN
            v_emp_rec := c_hierarchy$FETCH;
            c_hierarchy$ATTRIBUTES := row(c_hierarchy$ATTRIBUTES.isopen, c_hierarchy$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            c_hierarchy$ATTRIBUTES := row(c_hierarchy$ATTRIBUTES.isopen, c_hierarchy$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN c_hierarchy$ATTRIBUTES.notfound;
        /* 階層データの表示 */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'レベル: ', v_emp_rec.hierarchy_level, ', ID: ', v_emp_rec.employee_id, ', 名前: ', v_emp_rec.tree_display, ', 役職: ', v_emp_rec.job_title,
        CASE
            WHEN v_emp_rec.is_leaf = 1 THEN ', (リーフノード)'
            ELSE NULL
        END));
    END LOOP;
    CLOSE c_hierarchy;
    c_hierarchy := NULL;
    c_hierarchy$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => 'パス情報:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '-----------------------------');
    /* パス情報を表示するためのカーソル */

    DECLARE
        c_paths CURSOR FOR
        WITH RECURSIVE t (employee_id, employee_name, path)
        AS (SELECT
            employee_id, employee_name, employee_name::TEXT AS path
            FROM schema_sample.t_0012
            WHERE employee_id = p_root_id
        UNION ALL
        SELECT
            t_2.employee_id, t_2.employee_name, CONCAT_WS('', t.path, '/', t_2.employee_name::TEXT)
            FROM schema_sample.t_0012 AS t_2, t
            WHERE t.employee_id = t_2.manager_id)
        SELECT
            employee_id, employee_name, path
            FROM t
            ORDER BY path;
        c_paths$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
        v_path_rec schema_sample.null$c_paths := ROW (NULL, NULL, NULL)::schema_sample.null$c_paths;
        c_paths$FETCH RECORD;
    BEGIN
        SELECT
            NULL::DOUBLE PRECISION AS employee_id, NULL::CHARACTER VARYING(100) AS employee_name, NULL::VARCHAR(8000) AS path
            INTO c_paths$FETCH;
        c_paths := NULL;
        OPEN c_paths;
        c_paths$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);

        LOOP
            FETCH c_paths INTO c_paths$FETCH.employee_id, c_paths$FETCH.employee_name, c_paths$FETCH.path;

            IF FOUND THEN
                v_path_rec := c_paths$FETCH;
                c_paths$ATTRIBUTES := row(c_paths$ATTRIBUTES.isopen, c_paths$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
            ELSE
                c_paths$ATTRIBUTES := row(c_paths$ATTRIBUTES.isopen, c_paths$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
            END IF;
            EXIT WHEN c_paths$ATTRIBUTES.notfound;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_path_rec.employee_id, ', 名前: ', v_path_rec.employee_name, ', パス: ', v_path_rec.path));
        END LOOP;
        CLOSE c_paths;
        c_paths := NULL;
        c_paths$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    END;
    EXCEPTION
        WHEN others THEN
            IF c_hierarchy$ATTRIBUTES.isopen THEN
                CLOSE c_hierarchy;
                c_hierarchy := NULL;
                c_hierarchy$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0014_pivot_sample()
AS 
$BODY$
/* 結果を格納する変数 */
DECLARE
    v_jan DOUBLE PRECISION;
    v_feb DOUBLE PRECISION;
    v_mar DOUBLE PRECISION;
    v_apr DOUBLE PRECISION;
    r RECORD;
BEGIN
/* DUAL表を使ったPIVOT構文のサンプル */
/* まず、UNION ALLを使って複数行のデータを作成し、それをPIVOTする */
/* カーソルを使って結果を取得 */
    FOR r IN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT SUM(CASE
            WHEN month = 'JAN' THEN sales
            ELSE NULL::INTEGER
        END) AS jan, SUM(CASE
            WHEN month = 'FEB' THEN sales
            ELSE NULL::INTEGER
        END) AS feb, SUM(CASE
            WHEN month = 'MAR' THEN sales
            ELSE NULL::INTEGER
        END) AS mar, SUM(CASE
            WHEN month = 'APR' THEN sales
            ELSE NULL::INTEGER
        END) AS apr
        FROM (SELECT 'JAN' AS month, 100 AS sales
            FROM aws_oracle_ext.dual
        UNION ALL
        SELECT 'FEB' AS month, 150 AS sales
            FROM aws_oracle_ext.dual
        UNION ALL
        SELECT 'MAR' AS month, 200 AS sales
            FROM aws_oracle_ext.dual
        UNION ALL
        SELECT 'APR' AS month, 180 AS sales
            FROM aws_oracle_ext.dual) AS generatedSubquery
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    LOOP
        /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
        /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
        v_jan := r.jan;
        /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
        /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
        /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
        v_feb := r.feb;
        /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
        /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
        /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
        v_mar := r.mar;
        /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
        /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
        /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
        v_apr := r.apr;
        /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
        /* 結果を表示 */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '1月の売上: ', v_jan));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '2月の売上: ', v_feb));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '3月の売上: ', v_mar));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '4月の売上: ', v_apr));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '合計売上: ', (v_jan + v_feb + v_mar + v_apr)));
    END LOOP;
    /* 四半期ごとの集計を行うPIVOTの例 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '---四半期ごとの集計---');

    FOR r IN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT generatedAlias0.q1, generatedAlias0.q2
        FROM (SELECT generatedSubquery.quarter, SUM(CASE
                WHEN generatedSubquery.quarter = 'Q1' THEN generatedSubquery.sales
                ELSE NULL::INTEGER
            END) AS q1, SUM(CASE
                WHEN generatedSubquery.quarter = 'Q2' THEN generatedSubquery.sales
                ELSE NULL::INTEGER
            END) AS q2
            FROM (SELECT CASE
                    WHEN month IN ('JAN', 'FEB', 'MAR') THEN 'Q1'
                    WHEN month IN ('APR', 'MAY', 'JUN') THEN 'Q2'
                    WHEN month IN ('JUL', 'AUG', 'SEP') THEN 'Q3'
                    ELSE 'Q4'
                END AS quarter, sales
                FROM (SELECT 'JAN' AS month, 100 AS sales
                    FROM aws_oracle_ext.dual
                UNION ALL
                SELECT 'FEB' AS month, 150 AS sales
                    FROM aws_oracle_ext.dual
                UNION ALL
                SELECT 'MAR' AS month, 200 AS sales
                    FROM aws_oracle_ext.dual
                UNION ALL
                SELECT 'APR' AS month, 180 AS sales
                    FROM aws_oracle_ext.dual
                UNION ALL
                SELECT 'MAY' AS month, 190 AS sales
                    FROM aws_oracle_ext.dual
                UNION ALL
                SELECT 'JUN' AS month, 210 AS sales
                    FROM aws_oracle_ext.dual) AS generatedInnerSubquery) AS generatedSubquery
            GROUP BY generatedSubquery.quarter) AS generatedAlias0
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    LOOP
        BEGIN
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            RAISE NOTICE '第1四半期の売上: %', r.q1;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            RAISE NOTICE '第2四半期の売上: %', r.q2;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
        END;
    END LOOP;
    /* 複数の集計関数を使用したPIVOTの例 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '---複数の集計関数を使用した例---');

    FOR r IN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    WITH subquery0
    AS (SELECT 'JAN' AS month, 100 AS sales, 5 AS orders
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 'FEB' AS month, 150 AS sales, 7 AS orders
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 'MAR' AS month, 200 AS sales, 10 AS orders
        FROM aws_oracle_ext.dual)
    SELECT SUM(CASE
            WHEN month = 'JAN' THEN sales
            ELSE NULL::INTEGER
        END) AS alias3_alias1, AVG(CASE
            WHEN month = 'JAN' THEN orders
            ELSE NULL::INTEGER
        END) AS alias3_alias2, SUM(CASE
            WHEN month = 'FEB' THEN sales
            ELSE NULL::INTEGER
        END) AS alias4_alias1, AVG(CASE
            WHEN month = 'FEB' THEN orders
            ELSE NULL::INTEGER
        END) AS alias4_alias2, SUM(CASE
            WHEN month = 'MAR' THEN sales
            ELSE NULL::INTEGER
        END) AS alias5_alias1, AVG(CASE
            WHEN month = 'MAR' THEN orders
            ELSE NULL::INTEGER
        END) AS alias5_alias2
        FROM subquery0
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    LOOP
        BEGIN
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            RAISE NOTICE '1月の売上合計: %, 平均注文数: %', r.jan_sum_sales, r.jan_avg_orders;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            RAISE NOTICE '2月の売上合計: %, 平均注文数: %', r.feb_sum_sales, r.feb_avg_orders;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            RAISE NOTICE '3月の売上合計: %, 平均注文数: %', r.mar_sum_sales, r.mar_avg_orders;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
        END;
    END LOOP;
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0015_dynamic_search(IN p_table_name TEXT, IN p_search_conditions TEXT DEFAULT NULL, IN p_order_by TEXT DEFAULT NULL, IN p_max_rows DOUBLE PRECISION DEFAULT 100)
AS 
$BODY$
DECLARE
    aws_oracle_ext$array_id$temporary BIGINT;
    v_cursor REFCURSOR;
    v_cursor$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    v_sql CHARACTER VARYING(32767);
    v_column_count DOUBLE PRECISION;
    v_desc_tab VARCHAR(100) := 'v_desc_tab';
    v_cursor_id INTEGER;
    v_dummy INTEGER;
    v_column_value CHARACTER VARYING(4000);
    v_row_count DOUBLE PRECISION := 0;
    v_desc_tab$into VARCHAR(8000);
    v_cursor$FETCH RECORD;
BEGIN
/* 動的SQLの構築 */
    aws_oracle_ext$array_id$temporary := aws_oracle_ext.array$create_array(p_array_name => 'v_desc_tab', p_procedure_name => 'schema_sample.sct_0015_dynamic_search');
    PERFORM aws_oracle_ext.array$add_fields_to_array(p_array_id => aws_oracle_ext$array_id$temporary, p_fields => '[{"col_type":"INTEGER"},{"col_max_len":"INTEGER"},{"col_name":"CHARACTER VARYING(32)"},{"col_name_len":"INTEGER"},{"col_schema_name":"CHARACTER VARYING(32)"},{"col_schema_name_len":"INTEGER"},{"col_precision":"INTEGER"},{"col_scale":"INTEGER"},{"col_charsetid":"INTEGER"},{"col_charsetform":"INTEGER"},{"col_null_ok":"BOOLEAN"}]');
    PERFORM aws_oracle_ext.array$create_storage_table(p_array_name => 'v_desc_tab', p_procedure_name => 'schema_sample.sct_0015_dynamic_search', p_cast_type_name => 'desc_tab.dbms_sql$desc_tab', pWithData => FALSE);
    SELECT
        NULL::VARCHAR(8000) AS v_desc_tab
        INTO v_cursor$FETCH;
    v_sql := CONCAT_WS('', 'SELECT * FROM  ', p_table_name);

    IF p_search_conditions IS NOT NULL THEN
        v_sql := CONCAT_WS('', v_sql, ' WHERE  ', p_search_conditions);
    END IF;

    IF p_order_by IS NOT NULL THEN
        v_sql := CONCAT_WS('', v_sql, ' ORDER BY  ', p_order_by);
    END IF;
    v_sql := CONCAT_WS('', 'SELECT * FROM ( ', v_sql, ') AS var_sbq LIMIT CASE WHEN TRUNC($2::NUMERIC) > 0 THEN TRUNC($2::NUMERIC) ELSE 0 END');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '実行するSQL: ', v_sql));
    /* DBMS_SQLを使用してカラム情報を取得 */
    v_cursor_id := aws_oracle_ext.dbms_sql$open_cursor();
    PERFORM aws_oracle_ext.dbms_sql$parse((v_cursor_id)::INTEGER, (v_sql)::TEXT);
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    PERFORM aws_oracle_ext.dbms_sql$describe_columns((v_cursor_id)::INTEGER, v_column_count, v_desc_tab);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* カラム名を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');

    FOR i IN 1..v_column_count LOOP
        CALL aws_oracle_ext.dbms_output$put(a => RPAD((aws_oracle_ext.array$get_value(p_array_value_path => 'v_desc_tab[' || i || ']', p_procedure_name => 'schema_sample.sct_0015_dynamic_search', p_value_datatype => NULL::desc_rec.dbms_sql$desc_rec)).col_name, 20));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    /* カーソルをクローズ（情報取得のみに使用） */
    v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
    /* 動的カーソルを使用してデータを取得 */
    v_cursor := NULL;
    OPEN v_cursor FOR
    EXECUTE v_sql USING p_max_rows;
    v_cursor$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    /* 結果を取得して表示 */

    LOOP
        /* 各行のデータを取得 */
        v_desc_tab$into := NULL;
        FETCH v_cursor INTO v_cursor$FETCH.v_desc_tab;

        IF FOUND THEN
            v_desc_tab$into := v_cursor$FETCH.v_desc_tab;
            PERFORM aws_oracle_ext.array$set_value(p_array_path => 'v_desc_tab', p_procedure_name => 'schema_sample.sct_0015_dynamic_search', p_value => v_desc_tab$into);
            v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN v_cursor$ATTRIBUTES.notfound;
        /* 各カラムの値を表示 */

        FOR i IN 1..v_column_count LOOP
            CALL aws_oracle_ext.dbms_output$put(a => RPAD(COALESCE(aws_oracle_ext.TO_CHAR((aws_oracle_ext.array$get_value(p_array_value_path => 'v_desc_tab[' || i || ']', p_procedure_name => 'schema_sample.sct_0015_dynamic_search', p_value_datatype => NULL::desc_rec.dbms_sql$desc_rec)).col_name), ' '), 20));
        END LOOP;
        CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
        v_row_count := v_row_count + 1;
    END LOOP;
    /* カーソルを閉じる */
    CLOSE v_cursor;
    v_cursor$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '取得された行数: ', v_row_count));
    PERFORM aws_oracle_ext.array$clear_procedure('schema_sample.sct_0015_dynamic_search');
    EXCEPTION
        WHEN others THEN
            IF v_cursor$ATTRIBUTES.isopen THEN
                CLOSE v_cursor;
                v_cursor$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
            END IF;

            IF aws_oracle_ext.dbms_sql$is_open((v_cursor_id)::INTEGER) THEN
                v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0015_dynamic_update(IN p_table_name TEXT, IN p_id_column TEXT, IN p_id_value DOUBLE PRECISION, IN p_column_name TEXT, IN p_new_value TEXT, IN p_user_name TEXT DEFAULT SESSION_USER)
AS 
$BODY$
DECLARE
    v_sql CHARACTER VARYING(4000);
    v_old_value CHARACTER VARYING(4000);
    v_data_type CHARACTER VARYING(30);
    v_actual_new_value CHARACTER VARYING(4000);
    v_rows_updated DOUBLE PRECISION;
BEGIN
/* カラムのデータ型を取得 */
    BEGIN
        SELECT
            data_type
            INTO STRICT v_data_type
            FROM aws_oracle_ext.SYS_ALL_TAB_COLUMNS
            WHERE table_name = UPPER(p_table_name) AND column_name = UPPER(p_column_name);
        EXCEPTION
            WHEN no_data_found THEN
                RAISE USING hint = -20001, message = CONCAT_WS('', 'テーブルまたはカラムが存在しません: ', p_table_name, '.', p_column_name), detail = 'User-defined exception';
    END;
    /* 現在の値を取得 */
    v_sql := CONCAT_WS('', 'SELECT  ', p_column_name, ' FROM  ', p_table_name, ' WHERE  ', p_id_column, ' = $1');

    BEGIN
        EXECUTE v_sql INTO STRICT v_old_value USING p_id_value;
        EXCEPTION
            WHEN no_data_found THEN
                RAISE USING hint = -20002, message = CONCAT_WS('', 'ID ', p_id_value, ' のレコードが見つかりません。'), detail = 'User-defined exception';
    END;
    /* データ型に基づいて更新SQLを構築 */
    v_sql := CONCAT_WS('', 'UPDATE ', p_table_name, ' SET ', p_column_name, ' = ');

    IF v_data_type IN ('VARCHAR2', 'CHAR', 'VARCHAR', 'CLOB', 'NVARCHAR2', 'NCHAR') THEN
        v_sql := CONCAT_WS('', v_sql, ':new_value');
        v_actual_new_value := p_new_value;
    ELSIF v_data_type IN ('NUMBER', 'FLOAT', 'INTEGER', 'DECIMAL') THEN
        v_sql := CONCAT_WS('', v_sql, 'TO_NUMBER(:new_value)');
        v_actual_new_value := p_new_value;
    ELSIF v_data_type = 'DATE' THEN
        v_sql := CONCAT_WS('', v_sql, 'TO_DATE(:new_value, ''YYYY-MM-DD'')');
        v_actual_new_value := p_new_value;
    ELSIF v_data_type LIKE 'TIMESTAMP%' THEN
        v_sql := CONCAT_WS('', v_sql, 'TO_TIMESTAMP(:new_value, ''YYYY-MM-DD HH24:MI:SS.FF'')');
        v_actual_new_value := p_new_value;
    ELSE
        v_sql := CONCAT_WS('', v_sql, ':new_value');
        v_actual_new_value := p_new_value;
    END IF;
    v_sql := CONCAT_WS('', v_sql, ' WHERE ', p_id_column, ' = :id');
    /* 更新を実行 */
    EXECUTE v_sql USING v_actual_new_value, p_id_value;
    /* 影響を受けた行数を取得 */
    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
    /* 監査ログに記録 */
    INSERT INTO schema_sample.t_0015_log (log_id, operation, table_name, record_id, column_name, old_value, new_value, changed_by)
    VALUES (nextval('schema_sample.t_0015_log_seq'), 'UPDATE', p_table_name, p_id_value, p_column_name, v_old_value, p_new_value, p_user_name);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '更新が完了しました。影響を受けた行数: ', v_rows_updated));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'テーブル: ', p_table_name));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', p_id_value));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'カラム: ', p_column_name));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '旧値: ', v_old_value));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '新値: ', p_new_value));
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    EXCEPTION
        WHEN others THEN
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0016_dynamic_bulk_collect(IN p_condition TEXT DEFAULT NULL, IN p_batch_size DOUBLE PRECISION DEFAULT 10)
AS 
$BODY$
/* 動的SQLの結果を格納するためのレコード型とコレクション型を定義 */
DECLARE
    /* データを格納するコレクション */
    v_records schema_sample.sct_0016_dynamic_bulk_collect$t_record_table;
    /* 動的SQL文を格納する変数 */
    v_sql CHARACTER VARYING(4000);
    /* 処理した行数を格納する変数 */
    v_row_count INTEGER;
    v_total_rows INTEGER := 0;
BEGIN
/* SQL文を構築 */
    v_sql := 'SELECT ID, NAME, VALUE, CREATED_DATE FROM T_0016';

    IF p_condition IS NOT NULL THEN
        v_sql := CONCAT_WS('', v_sql, ' WHERE ', p_condition);
    END IF;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '実行するSQL: ', v_sql));
    /* BULK COLLECTを使用してデータを一括取得 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    EXECUTE v_sql;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_row_count := COALESCE(array_length(v_records, 1), 0);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '取得した行数: ', v_row_count));
    /* バッチサイズごとに処理 */

    FOR i IN 0..CEIL(v_row_count / p_batch_size) - 1 LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '===== バッチ ', (i + 1), ' ====='));
        /* バッチ内のレコードを処理 */

        FOR j IN 1..aws_oracle_ext.least(p_batch_size::DOUBLE PRECISION, (v_row_count - i * p_batch_size)::DOUBLE PRECISION) LOOP
            v_total_rows := v_total_rows + 1;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', ((v_records)[i * p_batch_size + j]).id, ', NAME: ', ((v_records)[i * p_batch_size + j]).name, ', VALUE: ', ((v_records)[i * p_batch_size + j]).value, ', DATE: ', aws_oracle_ext.TO_CHAR(((v_records)[i * p_batch_size + j]).created_date, 'YYYY-MM-DD')));
        END LOOP;
    END LOOP;
    /* 処理の統計情報を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '処理完了: 合計 ', v_total_rows, ' 行を処理しました'));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0017_delete_from_materialized_view(IN p_id DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_name CHARACTER VARYING(100);
    v_value DOUBLE PRECISION;
BEGIN
/* 削除前にデータを取得 */
    SELECT
        name, value
        INTO STRICT v_name, v_value
        FROM schema_sample.t_0017_mv
        WHERE id = p_id;
    /* マテリアライズドビューから直接削除（PostgreSQLではサポートされていない） */
    
    /*
    [5095 - Severity CRITICAL - PostgreSQL doesn't support DML statements on materialized views. Revise your code to use the REFRESH MATERIALIZED VIEW statement.]
    DELETE FROM T_0017_MV
        WHERE ID = p_id
    */
    /* 結果を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'マテリアライズドビューから行を削除しました。');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', p_id));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '名前: ', v_name));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '値: ', v_value));
    /* コミット */
    
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    EXCEPTION
        WHEN no_data_found THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID ', p_id, ' のデータが見つかりません。'));
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0017_insert_into_materialized_view(IN p_id DOUBLE PRECISION, IN p_name TEXT, IN p_value DOUBLE PRECISION)
AS 
$BODY$
BEGIN
/* マテリアライズドビューに直接挿入（PostgreSQLではサポートされていない） */
    
    /*
    [5095 - Severity CRITICAL - PostgreSQL doesn't support DML statements on materialized views. Revise your code to use the REFRESH MATERIALIZED VIEW statement.]
    INSERT INTO T_0017_MV (ID, NAME, VALUE, CREATED_DATE)
        VALUES (p_id, p_name, p_value, SYSDATE)
    */
    /* 結果を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'マテリアライズドビューに新しい行を挿入しました。');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', p_id));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '名前: ', p_name));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '値: ', p_value));
    /* コミット */
    
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0017_update_materialized_view(IN p_id DOUBLE PRECISION, IN p_new_value DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_old_value DOUBLE PRECISION;
    v_count DOUBLE PRECISION;
BEGIN
/* マテリアライズドビューから現在の値を取得 */
    SELECT
        value
        INTO STRICT v_old_value
        FROM schema_sample.t_0017_mv
        WHERE id = p_id;
    /* マテリアライズドビューを直接更新（PostgreSQLではサポートされていない） */
    
    /*
    [5095 - Severity CRITICAL - PostgreSQL doesn't support DML statements on materialized views. Revise your code to use the REFRESH MATERIALIZED VIEW statement.]
    UPDATE T_0017_MV
        SET VALUE = p_new_value
        WHERE ID = p_id
    */
    /* 更新された行数を取得 */
    GET DIAGNOSTICS v_count = ROW_COUNT;
    /* 結果を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'マテリアライズドビューを更新しました。');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', p_id));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '旧値: ', v_old_value));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '新値: ', p_new_value));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '更新された行数: ', v_count));
    /* コミット */
    
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    EXCEPTION
        WHEN no_data_found THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID ', p_id, ' のデータが見つかりません。'));
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0018_oracle_hints_sample()
AS 
$BODY$
DECLARE
    v_result DOUBLE PRECISION;
    v_start_time TIMESTAMP(6) WITHOUT TIME ZONE;
    v_end_time TIMESTAMP(6) WITHOUT TIME ZONE;
    v_execution_time INTERVAL DAY TO SECOND;
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== Oracleヒント句のサンプル =====');
    /* 1. ALL_ROWS ヒント（コストベースオプティマイザに全行取得の最適化を指示） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '1. ALL_ROWSヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    SELECT COUNT(*)
        INTO STRICT v_result
        FROM (SELECT
            *
        UNION ALL
        SELECT
            *
        UNION ALL
        SELECT
            *) AS var_sbq;
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 2. FIRST_ROWS ヒント（最初の数行を高速に取得するよう最適化） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '2. FIRST_ROWSヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 3. FULL ヒント（テーブルのフルスキャンを強制） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '3. FULLヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual AS d;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 4. CACHE ヒント（テーブルをバッファキャッシュに保持） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '4. CACHEヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual AS d;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 5. NOCACHE ヒント（テーブルをバッファキャッシュに保持しない） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '5. NOCACHEヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual AS d;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 6. PARALLEL ヒント（並列実行を指定） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '6. PARALLELヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual AS d;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 7. NOPARALLEL ヒント（並列実行を無効化） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '7. NOPARALLELヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual AS d;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 8. DRIVING_SITE ヒント（分散クエリの実行場所を指定） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '8. DRIVING_SITEヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual AS d;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 9. APPEND ヒント（ダイレクトパスインサートを使用） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '9. APPENDヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    EXECUTE 'INSERT INTO dual SELECT ''X''';
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 10. RESULT_CACHE ヒント（結果をキャッシュ） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '10. RESULT_CACHEヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 11. NO_RESULT_CACHE ヒント（結果のキャッシュを無効化） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '11. NO_RESULT_CACHEヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 12. GATHER_PLAN_STATISTICS ヒント（実行計画の統計情報を収集） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '12. GATHER_PLAN_STATISTICSヒントの例:');
    v_start_time := aws_oracle_ext.systimestamp();
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT
            dummy
        INTO STRICT v_result
        FROM aws_oracle_ext.dual;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    v_end_time := aws_oracle_ext.systimestamp();
    v_execution_time := v_end_time - v_start_time;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  結果: ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  実行時間: ', v_execution_time));
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== ヒント句のサンプル実行完了 =====');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0019_process_orders(IN p_batch_size DOUBLE PRECISION DEFAULT 100)
AS 
$BODY$
/* 注文データを格納するレコード型とコレクション型 */
DECLARE
    /* 処理する注文データ */
    v_orders schema_sample.sct_0019_process_orders$t_order_tab;
    /* 注文IDを格納するコレクション */
    v_order_ids schema_sample.sct_0019_process_orders$t_order_id_tab;
    /* 次の注文ID */
    v_next_order_id DOUBLE PRECISION;
    /* カーソルの定義 */
    c_products CURSOR FOR
    SELECT product_id, product_name, stock_quantity
        FROM schema_sample.t_0019_products
        WHERE stock_quantity > 0
        ORDER BY product_id;
    c_products$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    /* 商品データを格納するコレクション型 */
    /* 商品データを格納するコレクション変数 */
    v_product_ids schema_sample.sct_0019_process_orders$t_product_id_tab;
    v_product_names schema_sample.sct_0019_process_orders$t_product_name_tab;
    v_stock_qtys schema_sample.sct_0019_process_orders$t_stock_qty_tab;
    /* 成功した注文数 */
    v_success_count DOUBLE PRECISION := 0;
    /* 在庫不足で失敗した注文数 */
    v_failed_count DOUBLE PRECISION := 0;
    exception_exists BOOLEAN := false;
    cur_rec RECORD;
    aws_rec_indx INTEGER := 0;
    aws_exception_indx INTEGER := 0;
    rec RECORD;
BEGIN
/* 現在の最大注文IDを取得 */
    SELECT COALESCE(MAX(order_id), 0)
        INTO STRICT v_next_order_id
        FROM schema_sample.t_0019_orders;
    v_next_order_id := v_next_order_id + 1;
    /* カーソルから商品データを一括取得 */
    c_products := NULL;
    OPEN c_products;
    c_products$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    SELECT
        ARRAY_AGG(blk)
        INTO STRICT v_product_ids
        FROM aws_oracle_ext.bulk$fetch_cursor(pCur => c_products, pRecordType => NULL::DOUBLE PRECISION, pLimit => p_batch_size)
            AS blk;
    CLOSE c_products;
    c_products := NULL;
    c_products$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '取得した商品数: ', COALESCE(array_length(v_product_ids, 1), 0)));
    /* 注文データを生成（デモ用） */
    v_orders := ARRAY[]::schema_sample.sct_0019_process_orders$t_order_tab;
    v_orders := aws_oracle_ext.collection_extend(pcollection => v_orders, pcount => COALESCE(array_length(v_product_ids, 1), 0));
    v_order_ids := ARRAY[]::schema_sample.sct_0019_process_orders$t_order_id_tab;
    v_order_ids := aws_oracle_ext.collection_extend(pcollection => v_order_ids, pcount => COALESCE(array_length(v_product_ids, 1), 0));

    FOR i IN 1..COALESCE(array_length(v_product_ids, 1), 0) LOOP
        /* 注文数量はランダムに生成（在庫の10%～50%） */
        v_orders[i] := ROW ((v_product_ids)[i], v_orders[i].order_quantity);
        v_orders[i] := ROW (v_orders[i].product_id, FLOOR((v_stock_qtys)[i] * (aws_oracle_ext.dbms_random$value(10, 50)::NUMERIC / 100::NUMERIC)));
        v_order_ids := aws_oracle_ext.collection_element_set(pcollection => v_order_ids, ppath => ARRAY[i]::NUMERIC(10, 0)[], pval => v_next_order_id + i - 1::DOUBLE PRECISION);
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '商品ID: ', (v_product_ids)[i], ', 商品名: ', (v_product_names)[i], ', 在庫数: ', (v_stock_qtys)[i], ', 注文数: ', ((v_orders)[i]).order_quantity));
    END LOOP;
    /* 注文データを一括挿入 */
    
    /* [9996 - Severity CRITICAL - Transformer error occurred in insertStatement. Please submit report to developers.] */
    /* BULK_ROWCOUNTを使用して挿入結果を確認 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '注文挿入結果:');

    FOR i IN 1..COALESCE(array_length(v_orders, 1), 0) LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '注文 ', i, ': ', ' 行挿入'));
    END LOOP;
    /* 在庫を更新（注文数を減算） */

    BEGIN
        PERFORM aws_oracle_ext.bulk_exceptions$create_array(p_procedure_name => 'schema_sample.sct_0019_process_orders');
        aws_rec_indx := 0;

        FOR cur_rec IN
        SELECT
            (v_orders_coll).order_quantity, (v_orders_coll).product_id, (v_orders_coll).order_quantity
            FROM ROWS FROM (aws_oracle_ext.table(pVal => v_orders, pValType => 'NESTEDREC', pTypeToCast => 'schema_sample.sct_0019_process_orders$t_order_rec$r', pIndexes => ARRAY(SELECT
                aws_bounds
                FROM GENERATE_SERIES(ROUND(1)::BIGINT, ROUND(COALESCE(array_length(v_orders, 1), 0))::BIGINT)
                    AS aws_bounds (aws_bounds))) AS (v_orders_coll schema_sample.sct_0019_process_orders$t_order_rec$r))
        LOOP
            BEGIN
                aws_rec_indx := aws_rec_indx + 1;
                UPDATE schema_sample.t_0019_products AS e
                SET stock_quantity = stock_quantity - cur_rec.order_quantity, last_update_date = (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
                WHERE e.product_id = cur_rec.product_id AND e.stock_quantity >= cur_rec.order_quantity;
                EXCEPTION
                    WHEN OTHERS THEN
                        aws_exception_indx := aws_exception_indx + 1;
                        PERFORM aws_oracle_ext.array$set_value(p_array_path => 'bulk_exceptions[' || aws_exception_indx || ']', p_procedure_name => 'schema_sample.sct_0019_process_orders', p_value => (aws_rec_indx, SQLSTATE, SQLERRM)::aws_oracle_ext.sql$bulk_exceptions);
                        exception_exists := TRUE;
            END;
        END LOOP;

        IF exception_exists THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            ROLLBACK;
            RAISE;
            PERFORM aws_oracle_ext.array$delete('bulk_exceptions', p_procedure_name => 'schema_sample.sct_0019_process_orders');
            RETURN;
        END IF;
        PERFORM aws_oracle_ext.array$delete('bulk_exceptions', 'schema_sample.sct_0019_process_orders');
        /* BULK_ROWCOUNTを使用して更新結果を確認 */
        CALL aws_oracle_ext.dbms_output$put_line(a => '在庫更新結果:');

        FOR i IN 1..COALESCE(array_length(v_orders, 1), 0) LOOP
            /*
            [9996 - Severity CRITICAL - Transformer error occurred in relationalExpression. Please submit report to developers.]
            IF SQL%BULK_ROWCOUNT(i) > 0 THEN
                            DBMS_OUTPUT.PUT_LINE('商品ID ' || v_orders(i).product_id ||
                                               ': 在庫を ' || v_orders(i).order_quantity || ' 減少');
                            v_success_count := v_success_count + 1;
                        ELSE
                            DBMS_OUTPUT.PUT_LINE('商品ID ' || v_orders(i).product_id ||
                                               ': 在庫不足のため更新できませんでした');
                            v_failed_count := v_failed_count + 1;
                        END IF
            */
            BEGIN
            END;
        END LOOP;
        EXCEPTION
            WHEN others THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => '在庫更新中にエラーが発生しました');
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラー数: ', aws_oracle_ext.array$count('bulk_exceptions', 'schema_sample.sct_0019_process_orders')::TEXT));

                FOR i IN 1..aws_oracle_ext.array$count('bulk_exceptions', 'schema_sample.sct_0019_process_orders')::TEXT LOOP
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラー ', i, ' (インデックス ', (aws_oracle_ext.array$get_value(p_array_value_path => 'bulk_exceptions[' || i || ']'::VARCHAR, p_procedure_name => 'schema_sample.sct_0019_process_orders'::VARCHAR, p_value_datatype => (NULL, NULL, NULL)::aws_oracle_ext.sql$bulk_exceptions)).error_index, '): ', (aws_oracle_ext.array$get_value(p_array_value_path => 'bulk_exceptions[' || i || ']'::VARCHAR, p_procedure_name => 'schema_sample.sct_0019_process_orders'::VARCHAR, p_value_datatype => (NULL, NULL, NULL)::aws_oracle_ext.sql$bulk_exceptions)).sqlerrm));
                    v_failed_count := v_failed_count + 1;
                END LOOP;
    END;
    /* 在庫不足の注文を削除 */
    
    /* [9996 - Severity CRITICAL - Transformer error occurred in deleteStatement. Please submit report to developers.] */
    /* BULK_ROWCOUNTを使用して削除結果を確認 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '注文削除結果:');

    FOR i IN 1..COALESCE(array_length(v_orders, 1), 0) LOOP
        /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
        /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
        DECLARE
            generatedRowCount NUMERIC(38);
        BEGIN
            GET DIAGNOSTICS generatedRowCount = ROW_COUNT;

            IF generatedRowCount > 0 THEN
                RAISE NOTICE '注文ID %: 在庫不足のため削除', (v_order_ids)[i](i);
            END IF;
        END;
        /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
        BEGIN
        END;
    END LOOP;
    /* 処理結果の要約 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '処理結果要約:');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '成功した注文数: ', v_success_count));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '失敗した注文数: ', v_failed_count));
    /* 更新後の在庫状況を確認 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '更新後の在庫状況:');

    FOR rec IN
    SELECT product_id, product_name, stock_quantity
        FROM schema_sample.t_0019_products
        ORDER BY product_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '商品ID: ', rec.product_id, ', 商品名: ', rec.product_name, ', 在庫数: ', rec.stock_quantity));
    END LOOP;
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'すべての処理が完了しました');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0020_simple_forall()
AS 
$BODY$
/* データを格納するコレクション型 */
DECLARE
    /* コレクション変数 */
    v_ids schema_sample.sct_0020_simple_forall$t_id_tab;
    v_values schema_sample.sct_0020_simple_forall$t_value_tab;
    v_new_values schema_sample.sct_0020_simple_forall$t_value_tab;
    sql$rowcount BIGINT;
BEGIN
/* データの取得 */
    SELECT
        ARRAY_AGG(blk.id), ARRAY_AGG(blk.value)
        INTO v_ids, v_values
        FROM (SELECT
            id AS id, value AS value
            FROM schema_sample.t_0020_data) AS blk;
    /* 新しい値の計算 */
    v_new_values := ARRAY[]::schema_sample.sct_0020_simple_forall$t_value_tab;
    v_new_values := aws_oracle_ext.collection_extend(pcollection => v_new_values, pcount => COALESCE(array_length(v_ids, 1), 0));

    FOR i IN 1..COALESCE(array_length(v_ids, 1), 0) LOOP
        v_new_values := aws_oracle_ext.collection_element_set(pcollection => v_new_values, ppath => ARRAY[i]::NUMERIC(10, 0)[], pval => (v_values)[i] * 2::DOUBLE PRECISION);
    END LOOP;
    /* FORALLを使用した一括更新 */
    
    /* [9996 - Severity CRITICAL - Transformer error occurred in updateStatement. Please submit report to developers.] */
    /* 更新後に個別に値を表示 */
    FOR i IN 1..COALESCE(array_length(v_ids, 1), 0) LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', (v_ids)[i], ', 旧値: ', (v_values)[i], ', 新値: ', (v_new_values)[i]));
    END LOOP;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '処理が完了しました。更新件数: ', sql$rowcount));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0021_cross_join()
AS 
$BODY$
DECLARE
    v_count DOUBLE PRECISION := 0;
    rec RECORD;
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => '部門と従業員のクロスジョイン結果:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    CALL aws_oracle_ext.dbms_output$put_line(a => '部門ID | 部門名 | 従業員ID | 従業員名 | 給与');
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    /* クロスジョインを実行 */

    FOR rec IN
    SELECT
        d.dept_id, d.dept_name, e.emp_id, e.emp_name, e.salary
        FROM schema_sample.t_0021_departments AS d
        CROSS JOIN schema_sample.t_0021_employees AS e
        ORDER BY d.dept_id, e.emp_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', LPAD(rec.dept_id::TEXT, 6), ' | ', RPAD(rec.dept_name, 8), ' | ', LPAD(rec.emp_id::TEXT, 8), ' | ', RPAD(rec.emp_name, 8), ' | ', LPAD(aws_oracle_ext.TO_CHAR(rec.salary, '9,999.99'), 8)));
        v_count := v_count + 1;
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '合計: ', v_count, ' 行'));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0022_xmlsequece()
AS 
$BODY$
DECLARE
    v_xml VARCHAR(8000);
BEGIN
    SELECT
        XMLSEQUENCE(array_to_string(xpath('/EMPLOYEES/*', xml_data), '')::XML)
        INTO STRICT v_xml
        FROM schema_sample.t_0022
        WHERE id = 1;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0023_process_with_lock(IN p_id DOUBLE PRECISION, IN p_increment DOUBLE PRECISION DEFAULT 100, IN p_lock_mode DOUBLE PRECISION DEFAULT 0)
AS 
$BODY$
/* 0: デフォルト, 1: NOWAIT, 2: WAIT 5秒, 3: WAIT 10秒 */
DECLARE
    v_name CHARACTER VARYING(100);
    v_value DOUBLE PRECISION;
    v_status CHARACTER VARYING(20);
BEGIN
/* SELECT FOR UPDATEを使用してレコードをロック */
    BEGIN
        CASE p_lock_mode
            WHEN 1 THEN
                /* NOWAITオプション */
                SELECT
                    name, value, status
                    INTO STRICT v_name, v_value, v_status
                    FROM schema_sample.t_0023
                    WHERE id = p_id
                    FOR UPDATE NOWAIT;
                CALL aws_oracle_ext.dbms_output$put_line(a => 'レコードをNOWAITオプションでロックしました。');
            WHEN 2 THEN
                /* WAIT 5秒 */
                SELECT
                    name, value, status
                    INTO STRICT v_name, v_value, v_status
                    FROM schema_sample.t_0023
                    WHERE id = p_id;
                CALL aws_oracle_ext.dbms_output$put_line(a => 'レコードをWAIT 5秒オプションでロックしました。');
            WHEN 3 THEN
                /* WAIT 10秒 */
                SELECT
                    name, value, status
                    INTO STRICT v_name, v_value, v_status
                    FROM schema_sample.t_0023
                    WHERE id = p_id;
                CALL aws_oracle_ext.dbms_output$put_line(a => 'レコードをWAIT 10秒オプションでロックしました。');
            ELSE
                /* デフォルト：無期限に待機 */
                SELECT
                    name, value, status
                    INTO STRICT v_name, v_value, v_status
                    FROM schema_sample.t_0023
                    WHERE id = p_id
                    FOR UPDATE;
                CALL aws_oracle_ext.dbms_output$put_line(a => 'レコードをデフォルトオプションでロックしました。');
        END CASE;
        /* 以下は同じ処理を続ける... */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', p_id, ', 名前: ', v_name, ', 値: ', v_value, ', 状態: ', v_status));
        UPDATE schema_sample.t_0023
        SET value = v_value + p_increment, last_updated = (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
            WHERE id = p_id;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '値を ', v_value, ' から ', (v_value + p_increment), ' に更新しました。'));
        /*
        [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
        COMMIT
        */
        CALL aws_oracle_ext.dbms_output$put_line(a => 'トランザクションをコミットしました。');
        EXCEPTION
            WHEN no_data_found THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID ', p_id, ' のレコードが見つかりませんでした。'));
                /*
                [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
                ROLLBACK
                */
            WHEN others THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
                /*
                [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
                ROLLBACK
                */
    END;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0030_get_employees_typed(IN p_department TEXT, OUT p_cursor REFCURSOR)
AS 
$BODY$
/* 独自のREF CURSOR型を定義 */
DECLARE
    v_emp_cursor REFCURSOR;
    v_emp_cursor$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
BEGIN
/* 部署が指定されている場合はフィルタリング、そうでなければ全件取得 */
    IF p_department IS NOT NULL THEN
        v_emp_cursor := NULL;
        OPEN v_emp_cursor FOR
        SELECT
            *
            FROM schema_sample.t_0030
            WHERE department = p_department
            ORDER BY employee_id;
        v_emp_cursor$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    ELSE
        v_emp_cursor := NULL;
        OPEN v_emp_cursor FOR
        SELECT
            *
            FROM schema_sample.t_0030
            ORDER BY employee_id;
        v_emp_cursor$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    END IF;
    /* 出力パラメータに代入 */
    p_cursor := v_emp_cursor::REFCURSOR;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0038_dual()
AS 
$BODY$
DECLARE
    v_txt CHARACTER VARYING(100);
BEGIN
    SELECT
        'x'
        INTO STRICT v_txt;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0039_create_basic_job(IN p_job_name TEXT, IN p_start_date TIMESTAMP WITHOUT TIME ZONE DEFAULT aws_oracle_ext.systimestamp(), IN p_repeat_interval TEXT DEFAULT 'FREQ=DAILY; INTERVAL=1')
AS 
$BODY$
BEGIN
/* 既存のジョブがあれば削除 */
    BEGIN
        BEGIN
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            SELECT cron.unschedule(p_job_name);
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            /* ジョブが存在しない場合は無視 */
        END;
        EXCEPTION
            WHEN others THEN
                NULL;
    END;
    /* 新しいジョブを作成 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT cron.schedule(p_job_name, p_repeat_interval, 'BEGIN RAISE NOTICE ''ジョブ実行: '' || TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS.US''); END;');
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ジョブ ', p_job_name, ' が作成されました'));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0042_demo_cursor_already_open()
AS 
$BODY$
/* 明示的カーソルの宣言 */
DECLARE
    c_items CURSOR FOR
    SELECT
        id, name, value
        FROM schema_sample.t_0042
        ORDER BY id;
    c_items$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    /* レコード変数の宣言 */
    v_item_rec schema_sample.sct_0042_demo_cursor_already_open$c_items := ROW (NULL, NULL, NULL)::schema_sample.sct_0042_demo_cursor_already_open$c_items;
    c_items$FETCH RECORD;
BEGIN
/* カーソルを開く */
    SELECT
        NULL::DOUBLE PRECISION AS id, NULL::CHARACTER VARYING(100) AS name, NULL::DOUBLE PRECISION AS value
        INTO c_items$FETCH;
    c_items := NULL;
    OPEN c_items;
    c_items$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    /* 最初のレコードを取得 */
    FETCH c_items INTO c_items$FETCH.id, c_items$FETCH.name, c_items$FETCH.value;

    IF FOUND THEN
        v_item_rec := c_items$FETCH;
        c_items$ATTRIBUTES := row(c_items$ATTRIBUTES.isopen, c_items$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
    ELSE
        c_items$ATTRIBUTES := row(c_items$ATTRIBUTES.isopen, c_items$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
    END IF;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '最初のレコード: ID=', v_item_rec.id, ', NAME=', v_item_rec.name));
    /* 意図的に同じカーソルを再度開こうとする（CURSOR_ALREADY_OPEN例外が発生） */

    BEGIN
        OPEN c_items;
        c_items$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
        /* このカーソルは既に開いているため例外が発生 */
        CALL aws_oracle_ext.dbms_output$put_line(a => 'この行は実行されません');
    /*
    [5562 - Severity CRITICAL - DMS SC can't convert the CURSOR_ALREADY_OPEN exception with the current local cursor conversion logic. Revise your code to use another type of exception and try again.]
    WHEN CURSOR_ALREADY_OPEN THEN
                DBMS_OUTPUT.PUT_LINE('CURSOR_ALREADY_OPEN例外が発生しました: カーソルは既に開いています');
    */
    /*
    [5580 - Severity CRITICAL - The exception block in the converted code is empty. Review the converted code and convert your source code manually where necessary.]
    EXCEPTION
           WHEN CURSOR_ALREADY_OPEN THEN
               DBMS_OUTPUT.PUT_LINE('CURSOR_ALREADY_OPEN例外が発生しました: カーソルは既に開いています');
    */
    END;
    /* 残りのレコードを処理 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '残りのレコードを処理します:');

    LOOP
        FETCH c_items INTO c_items$FETCH.id, c_items$FETCH.name, c_items$FETCH.value;

        IF FOUND THEN
            v_item_rec := c_items$FETCH;
            c_items$ATTRIBUTES := row(c_items$ATTRIBUTES.isopen, c_items$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            c_items$ATTRIBUTES := row(c_items$ATTRIBUTES.isopen, c_items$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN c_items$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'レコード: ID=', v_item_rec.id, ', NAME=', v_item_rec.name));
    END LOOP;
    /* カーソルを閉じる */
    CLOSE c_items;
    c_items := NULL;
    c_items$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    /* 閉じたカーソルを再度開く（これは正常に動作する） */

    BEGIN
        OPEN c_items;
        c_items$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
        CALL aws_oracle_ext.dbms_output$put_line(a => 'カーソルを再度開きました');
        CLOSE c_items;
        c_items := NULL;
        c_items$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
        EXCEPTION
            WHEN others THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '予期しないエラーが発生しました: ', SQLERRM));
    END;
    EXCEPTION
        WHEN others THEN
            /* メインブロックでの例外処理 */
            IF c_items$ATTRIBUTES.isopen THEN
                CLOSE c_items;
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0043_complex_dynamic_sql(IN p_expression TEXT)
AS 
$BODY$
DECLARE
    aws_oracle_ext$array_id$temporary BIGINT;
    v_sql CHARACTER VARYING(4000);
    v_cursor_id NUMERIC(38);
    v_result CHARACTER VARYING(4000);
    v_cols VARCHAR(100) := 'v_cols';
    v_col_cnt DOUBLE PRECISION;
BEGIN
/* 複雑なダイナミックSQL文を構築 */
    aws_oracle_ext$array_id$temporary := aws_oracle_ext.array$create_array(p_array_name => 'v_cols', p_procedure_name => 'schema_sample.sct_0043_complex_dynamic_sql');
    PERFORM aws_oracle_ext.array$add_fields_to_array(p_array_id => aws_oracle_ext$array_id$temporary, p_fields => '[{"col_type":"INTEGER"},{"col_max_len":"INTEGER"},{"col_name":"CHARACTER VARYING(32)"},{"col_name_len":"INTEGER"},{"col_schema_name":"CHARACTER VARYING(32)"},{"col_schema_name_len":"INTEGER"},{"col_precision":"INTEGER"},{"col_scale":"INTEGER"},{"col_charsetid":"INTEGER"},{"col_charsetform":"INTEGER"},{"col_null_ok":"BOOLEAN"}]');
    PERFORM aws_oracle_ext.array$create_storage_table(p_array_name => 'v_cols', p_procedure_name => 'schema_sample.sct_0043_complex_dynamic_sql', p_cast_type_name => 'desc_tab.dbms_sql$desc_tab', pWithData => FALSE);
    v_sql := CONCAT_WS('', 'SELECT  ', p_expression, ' ');
    /* DBMS_SQLを使用して動的SQLを実行 */
    v_cursor_id := aws_oracle_ext.dbms_sql$open_cursor();
    PERFORM aws_oracle_ext.dbms_sql$parse((v_cursor_id)::INTEGER, (v_sql)::TEXT);
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    PERFORM aws_oracle_ext.dbms_sql$describe_columns((v_cursor_id)::INTEGER, v_col_cnt, v_cols);
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* 結果列を定義 */
    PERFORM aws_oracle_ext.dbms_sql$define_column((v_cursor_id)::INTEGER, (1)::INTEGER, v_result, (4000)::INTEGER);
    /* 実行して結果を取得 */

    IF aws_oracle_ext.dbms_sql$execute((v_cursor_id)::INTEGER) > 0 THEN
        IF aws_oracle_ext.dbms_sql$fetch_rows((v_cursor_id)::INTEGER) > 0 THEN
            SELECT
                p_column_val
                INTO v_result
                FROM aws_oracle_ext.dbms_sql$column_value((v_cursor_id)::INTEGER, (1)::INTEGER, v_result);
        END IF;
    END IF;
    v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '結果: ', v_result));
    PERFORM aws_oracle_ext.array$clear_procedure('schema_sample.sct_0043_complex_dynamic_sql');
    EXCEPTION
        WHEN others THEN
            IF aws_oracle_ext.dbms_sql$is_open((v_cursor_id)::INTEGER) THEN
                v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
            END IF;
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0043_complex_raw_operations(IN p_input1 TEXT, IN p_input2 TEXT)
AS 
$BODY$
DECLARE
    v_raw1 BYTEA;
    v_raw2 BYTEA;
    v_result BYTEA;
    v_bit_and BYTEA;
    v_bit_or BYTEA;
    v_bit_xor BYTEA;
    v_bit_not BYTEA;
    v_hex_result CHARACTER VARYING(400);
BEGIN
/* 入力をRAWに変換 */
    SELECT ENCODE(p_input1::BYTEA, 'hex'), ENCODE(p_input2::BYTEA, 'hex')
        INTO STRICT v_raw1, v_raw2;
    /* 複雑なRAW操作 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT aws_oracle_ext.utl_raw$concat(r1 => SUBSTRING(v_raw1 FROM 1 FOR 3), r2 => OVERLAY(v_raw2 PLACING v_raw1 FROM 1 FOR octet_length(v_raw2)), r3 => repeat(decode('A5', 'hex'), 3)), aws_oracle_ext.utl_raw$bit_and(v_raw1, v_raw2), aws_oracle_ext.utl_raw$bit_or(v_raw1, v_raw2), aws_oracle_ext.utl_raw$bit_xor(v_raw1, v_raw2), aws_oracle_ext.utl_raw$bit_complement(v_raw1)
        INTO STRICT v_result, v_bit_and, v_bit_or, v_bit_xor, v_bit_not
        FROM aws_oracle_ext.dual;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* 結果を16進数に変換 */
    SELECT UPPER(ENCODE(v_result, 'hex'))
        INTO STRICT v_hex_result;
    /* 結果を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'RAW1: ', v_raw1));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'RAW2: ', v_raw2));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '結果 (RAW): ', v_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '結果 (HEX): ', v_hex_result));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'BIT_AND: ', v_bit_and));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'BIT_OR: ', v_bit_or));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'BIT_XOR: ', v_bit_xor));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'BIT_NOT: ', v_bit_not));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0043_labeled_blocks_with_goto(IN p_max_count DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_counter DOUBLE PRECISION := 0;
    v_result CHARACTER VARYING(100);
BEGIN
    <<outer_block>>
    BEGIN
        v_counter := 0;

        <<inner_loop>>
        LOOP
            <<continue_loop>>
            BEGIN
                v_counter := v_counter + 1;
                SELECT
                    aws_oracle_ext.TO_CHAR(v_counter)
                    INTO STRICT v_result;

                BEGIN
                    <<skip_output>>
                    BEGIN
                        IF MOD(v_counter, 3) = 0 THEN
                            EXIT skip_output;
                        END IF;
                        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'カウンター: ', v_result));
                    END;
                    NULL;
                    EXIT inner_loop WHEN (v_counter >= p_max_count);
                    EXCEPTION
                        WHEN others THEN
                            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '内部エラー: ', SQLERRM));
                            EXIT continue_loop;
                END;
            END;
            NULL;
        END LOOP inner_loop;
    END;
    CALL aws_oracle_ext.dbms_output$put_line(a => '処理完了');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '外部エラー: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0043_pragma_heavy_procedure(IN p_input TEXT)
AS 
$BODY$
DECLARE
    aws_params JSON := json_build_object('p_input', p_input);
    aws_session_env JSON;
BEGIN
    SELECT
        *
        FROM aws_oracle_ext.autonomous_exec('CALL schema_sample.sct_0043_pragma_heavy_procedure$at('||quote_nullable(aws_params)||','||quote_nullable(aws_session_env)||')')
        INTO aws_params, aws_session_env;
END
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0043_pragma_heavy_procedure$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
AS 
$BODY$
DECLARE
    e_custom_exception aws_oracle_ext.ora_exception := 'e_custom_exception';
    e_custom_exception$code SMALLINT := - 20001;
    /* 非標準のプラグマ */
    v_result CHARACTER VARYING(4000);
    p_input TEXT;
BEGIN
/* DUALテーブルを使用した単純なクエリ */
    SELECT
        t.p_input
        INTO p_input
        FROM json_to_record(aws_params)
            AS t (p_input TEXT);
    SELECT
        UPPER(p_input)
        INTO STRICT v_result;
    /* 複雑な例外処理ブロック */

    BEGIN
        IF v_result IS NULL THEN
            RAISE USING detail = e_custom_exception, hint = E_CUSTOM_EXCEPTION$code;
        END IF;
        EXCEPTION
            WHEN raise_exception THEN
                DECLARE
                    exc$name CHARACTER VARYING;
                    exc$code CHARACTER VARYING;
                BEGIN
                    GET STACKED DIAGNOSTICS exc$name := pg_exception_detail,
                        exc$code := pg_exception_hint;

                    IF exc$name = e_custom_exception OR exc$code = e_custom_exception$code::VARCHAR THEN
                        RAISE USING hint = -20001, message = '入力が無効です', detail = 'User-defined exception';
                    END IF;
                END;
            WHEN others THEN
                IF SQLSTATE BETWEEN - 20999 AND - 20000 THEN
                    RAISE;
                ELSE
                    RAISE USING hint = -20002, message = CONCAT_WS('', 'その他のエラー: ', SQLERRM), detail = 'User-defined exception';
                END IF;
    END;
    COMMIT;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '処理結果: ', v_result));
END;
$BODY$
LANGUAGE plpgsql;
COMMENT ON PROCEDURE schema_sample.sct_0043_pragma_heavy_procedure$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
     IS 'Belongs to: schema_sample.sct_0043_pragma_heavy_procedure';

CREATE OR REPLACE PROCEDURE schema_sample.sct_0043_xml_processing(IN p_input TEXT)
AS 
$BODY$
DECLARE
    v_xml XML;
    v_result CHARACTER VARYING(4000);
    v_node_value CHARACTER VARYING(1000);
BEGIN
/* 入力文字列からXMLを作成 */
    SELECT XMLPARSE (DOCUMENT CONCAT_WS('', '<root><item>', p_input, '</item></root>'))
        INTO STRICT v_xml;
    /* XMLPath関数を使用 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT (xpath('//self::text()', (xpath('/root/item/text()', v_xml))[1]))[1]::TEXT::VARCHAR(1000)
        INTO STRICT v_node_value;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* XMLElement関数を使用して新しいXMLを作成 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT XMLSERIALIZE (CONTENT XMLELEMENT (NAME "RESULT", XMLATTRIBUTES ((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) AS "TIMESTAMP"), XMLELEMENT (NAME "VALUE", v_node_value), XMLELEMENT (NAME "PROCESSED_BY", USER)) AS TEXT)
        INTO STRICT v_result
        FROM aws_oracle_ext.dual;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'XML結果: ', v_result));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0044_concat_raw_example(IN p_text1 TEXT, IN p_text2 TEXT)
AS 
$BODY$
DECLARE
    v_raw1 BYTEA;
    v_raw2 BYTEA;
    v_result BYTEA;
    v_text1 CHARACTER VARYING(4000);
BEGIN
/* 入力文字列をRAWに変換 */
    SELECT ENCODE(p_text1::BYTEA, 'hex')
        INTO STRICT v_raw1;
    SELECT ENCODE(p_text2::BYTEA, 'hex')
        INTO STRICT v_raw2;
    /* UTL_RAW.CONCATを使用して連結 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    SELECT aws_oracle_ext.utl_raw$concat(r1 => v_raw1, r2 => v_raw2)
        INTO STRICT v_result
        FROM aws_oracle_ext.dual;
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* 結果を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'RAW1: ', v_raw1));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'RAW2: ', v_raw2));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '連結結果 (RAW): ', v_result));
    /* RAWを文字列に戻す */
    SELECT DECODE(v_result::TEXT, 'hex')
        INTO STRICT v_text1;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '連結結果 (文字列): ', v_text1));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0045_oracle_date_timestamp_demo(IN p_date_string TEXT, IN p_timestamp_string TEXT)
AS 
$BODY$
/* 変数宣言 */
DECLARE
    v_date TIMESTAMP(0) WITHOUT TIME ZONE;
    v_timestamp TIMESTAMP(6) WITHOUT TIME ZONE;
    v_formatted_date CHARACTER VARYING(100);
    v_formatted_timestamp CHARACTER VARYING(100);
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => 'Oracle 日付・タイムスタンプ変換デモ');
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    /* TO_DATE を使用した日付変換（PostgreSQLと互換性がない書式） */
    /* Oracle固有の書式要素: RR（2桁年）、SYYYY（符号付き年）、J（ユリウス日）、TS（短い時間） */

    BEGIN
    /* RR書式（PostgreSQLにはない）を使用 */
        v_date := aws_oracle_ext.TO_DATE(p_date_string::TEXT, 'DD-MON-RR HH24:MI:SS');
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '入力文字列: ', p_date_string));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'TO_DATE変換結果: ', v_date));
        /* 別の書式で表示 */
        v_formatted_date := aws_oracle_ext.TO_CHAR(v_date, 'SYYYY-MM-DD HH24:MI:SS');
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'フォーマット済み日付: ', v_formatted_date));
        /* ユリウス日に変換（PostgreSQLにはない） */
        v_formatted_date := aws_oracle_ext.TO_CHAR(v_date, 'J');
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ユリウス日: ', v_formatted_date));
        EXCEPTION
            WHEN others THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '日付変換エラー: ', SQLERRM));
    END;
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    /* TO_TIMESTAMP を使用したタイムスタンプ変換（PostgreSQLと互換性がない書式） */
    /* Oracle固有の書式要素: FF（小数秒）、TZR（タイムゾーン地域）、TZD（タイムゾーン略称） */

    BEGIN
    /* FF9書式（PostgreSQLでは異なる動作）を使用 */
        v_timestamp := (to_timestamp(p_timestamp_string, 'DD-MON-YYYY HH24:MI:SS.FF9 TZR TZD'))::TIMESTAMP WITHOUT TIME ZONE;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '入力文字列: ', p_timestamp_string));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'TO_TIMESTAMP変換結果: ', v_timestamp));
        /* 別の書式で表示（Oracle固有の書式要素を使用） */
        v_formatted_timestamp := aws_oracle_ext.TO_CHAR(v_timestamp, 'YYYY-MM-DD HH24:MI:SS.FF9 TZH:TZM TZR');
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'フォーマット済みタイムスタンプ: ', v_formatted_timestamp));
        EXCEPTION
            WHEN others THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'タイムスタンプ変換エラー: ', SQLERRM));
    END;
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------');
    /* 追加の日付計算（Oracle固有の機能） */

    BEGIN
    /* 日付から日付への減算（PostgreSQLでは異なる結果） */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '現在日付から7日前: ', aws_oracle_ext.TO_CHAR((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) - (7::NUMERIC || ' days')::INTERVAL, 'DD-MON-YYYY')));
        /* 月の加算（ADD_MONTHS関数） */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '現在日付から3ヶ月後: ', aws_oracle_ext.TO_CHAR(aws_oracle_ext.ADD_MONTHS((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0), 3), 'DD-MON-YYYY')));
        /* 次の指定曜日（NEXT_DAY関数）- Oracle固有の曜日指定 */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '次の金曜日: ', aws_oracle_ext.TO_CHAR(aws_oracle_ext.NEXT_DAY((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0), 'FRIDAY'), 'DD-MON-YYYY')));
        /* 月の最終日（LAST_DAY関数） */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '今月の最終日: ', aws_oracle_ext.TO_CHAR(aws_oracle_ext.LAST_DAY((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)), 'DD-MON-YYYY')));
        EXCEPTION
            WHEN others THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '日付計算エラー: ', SQLERRM));
    END;
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'プロシージャ実行エラー: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0047_complex_outer_join_report(IN p_min_salary DOUBLE PRECISION DEFAULT 0)
AS 
$BODY$
DECLARE
    v_count DOUBLE PRECISION;
    rec RECORD;
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== 複雑な外部結合を使用したレポート =====');
    /* 例1: (+)演算子を使用した古い形式の外部結合 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '1. 部門に所属していない従業員も含めた一覧:');

    FOR rec IN
    SELECT
        e.employee_id, e.employee_name, e.salary, d.department_name, l.location_name
        FROM schema_sample.t_0047_employees AS e
        LEFT OUTER JOIN schema_sample.t_0047_departments AS d
            ON (e.department_id = d.department_id)
        LEFT OUTER JOIN schema_sample.t_0047_locations AS l
            ON (d.location_id = l.location_id)
        WHERE e.salary >= p_min_salary
        ORDER BY e.employee_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ID: ', rec.employee_id, ', 名前: ', rec.employee_name, ', 給与: ', rec.salary, ', 部門: ', COALESCE(rec.department_name, '未所属'), ', 場所: ', COALESCE(rec.location_name, '不明')));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 例2: 複数の条件を持つ外部結合 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '2. 複数の条件を持つ外部結合:');

    FOR rec IN
    SELECT
        e.employee_id, e.employee_name, d.department_name, l.location_name
        FROM schema_sample.t_0047_employees AS e
        LEFT OUTER JOIN schema_sample.t_0047_departments AS d
            ON (e.department_id = d.department_id)
        LEFT OUTER JOIN schema_sample.t_0047_locations AS l
            ON (d.location_id = l.location_id)
        WHERE (d.department_id = 10 OR d.department_id = 20 OR d.department_id IS NULL)
        ORDER BY e.employee_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ID: ', rec.employee_id, ', 名前: ', rec.employee_name, ', 部門: ', COALESCE(rec.department_name, '未所属'), ', 場所: ', COALESCE(rec.location_name, '不明')));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 例3: 外部結合とIN句の組み合わせ（修正版） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '3. 外部結合とIN句の組み合わせ:');

    FOR rec IN
    SELECT
        e.employee_id, e.employee_name, d.department_name
        FROM schema_sample.t_0047_employees AS e
        LEFT OUTER JOIN schema_sample.t_0047_departments AS d
            ON e.department_id = d.department_id AND d.location_id IN (SELECT
                location_id
                FROM schema_sample.t_0047_locations
                WHERE country = '日本')
        ORDER BY e.employee_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ID: ', rec.employee_id, ', 名前: ', rec.employee_name, ', 部門: ', COALESCE(rec.department_name, '未所属')));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 例4: 外部結合とEXISTS句の組み合わせ（修正版） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '4. 外部結合とEXISTS句の組み合わせ:');

    FOR rec IN
    SELECT
        e.employee_id, e.employee_name, d.department_name
        FROM schema_sample.t_0047_employees AS e
        LEFT OUTER JOIN schema_sample.t_0047_departments AS d
            ON e.department_id = d.department_id
        WHERE EXISTS (SELECT
            1
            FROM schema_sample.t_0047_projects AS p
            WHERE p.department_id = d.department_id AND p.end_date IS NULL) OR d.department_id IS NULL
        ORDER BY e.employee_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ID: ', rec.employee_id, ', 名前: ', rec.employee_name, ', 部門: ', COALESCE(rec.department_name, '未所属')));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 例5: 外部結合と相関サブクエリの組み合わせ（修正版） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '5. 外部結合と相関サブクエリの複雑な組み合わせ:');

    FOR rec IN
    SELECT
        e.employee_id, e.employee_name, d.department_name AS dept_name, COALESCE((SELECT
            COUNT(*)
            FROM schema_sample.t_0047_projects AS p
            WHERE p.department_id = e.department_id), 0) AS project_count
        FROM schema_sample.t_0047_employees AS e
        LEFT OUTER JOIN schema_sample.t_0047_departments AS d
            ON e.department_id = d.department_id
        WHERE e.salary > (SELECT
            AVG(salary)
            FROM schema_sample.t_0047_employees)
        ORDER BY e.employee_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ID: ', rec.employee_id, ', 名前: ', rec.employee_name, ', 部門: ', COALESCE(rec.dept_name, '未所属'), ', プロジェクト数: ', rec.project_count));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    /* 例6: 外部結合とCASE式の組み合わせ（修正版） */
    CALL aws_oracle_ext.dbms_output$put_line(a => '6. 外部結合とCASE式の組み合わせ:');

    FOR rec IN
    SELECT
        e.employee_id, e.employee_name,
        CASE
            WHEN d.department_id IS NULL THEN '未所属'
            WHEN d.location_id = 1 THEN CONCAT_WS('', d.department_name, ' (東京)')
            WHEN d.location_id = 2 THEN CONCAT_WS('', d.department_name, ' (NY)')
            ELSE d.department_name
        END AS department_info,
        CASE
            WHEN d.department_id IS NULL THEN 'プロジェクトなし'
            WHEN EXISTS (SELECT
                1
                FROM schema_sample.t_0047_projects AS p
                WHERE p.department_id = d.department_id) THEN 'プロジェクトあり'
            ELSE 'プロジェクトなし'
        END AS project_status
        FROM schema_sample.t_0047_employees AS e
        LEFT OUTER JOIN schema_sample.t_0047_departments AS d
            ON e.department_id = d.department_id
        ORDER BY e.employee_id
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ID: ', rec.employee_id, ', 名前: ', rec.employee_name, ', 部門情報: ', rec.department_info, ', プロジェクト状況: ', rec.project_status));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== レポート終了 =====');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0048_connect_by_nocycle_sample()
AS 
$BODY$
DECLARE
    v_level DOUBLE PRECISION;
    v_path CHARACTER VARYING(100);
    rec RECORD;
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== CONNECT BY NOCYCLEのサンプル =====');
    CALL aws_oracle_ext.dbms_output$put_line(a => '1. 数値シーケンスの生成:');
    /* 1から10までの数値シーケンスを生成 */

    FOR rec IN
    WITH RECURSIVE t (num)
    AS (SELECT
        (1)::NUMERIC AS num
    UNION ALL
    SELECT
        (t.num + 1)::NUMERIC AS num
        FROM t
        WHERE (t.level + 1)::NUMERIC <= 10)
    SELECT
        num
        FROM t
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ', rec.num));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '2. 日付シーケンスの生成:');
    /* 7日間の日付シーケンスを生成 */

    FOR rec IN
    WITH RECURSIVE t (date_value, date_str)
    AS (SELECT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) + (((1)::NUMERIC - 1)::NUMERIC || ' days')::INTERVAL AS date_value,
            aws_oracle_ext.TO_CHAR((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) + (((1)::NUMERIC - 1)::NUMERIC || ' days')::INTERVAL, 'YYYY-MM-DD') AS date_str, (1)::NUMERIC AS level
    UNION ALL
    SELECT (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) + (((t.level + 1)::NUMERIC - 1)::NUMERIC || ' days')::INTERVAL AS date_value,
            aws_oracle_ext.TO_CHAR((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) + (((t.level + 1)::NUMERIC - 1)::NUMERIC || ' days')::INTERVAL, 'YYYY-MM-DD') AS date_str, (t.level + 1)::NUMERIC AS level
        FROM t
        WHERE (t.level + 1)::NUMERIC <= 7)
    SELECT
        date_value, date_str
        FROM t
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ', rec.date_str));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '3. 階層構造の生成（NOCYCLEの使用）:');
    /* 階層構造を生成（循環参照を防ぐためにNOCYCLEを使用） */

    FOR rec IN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    WITH RECURSIVE t (depth, node_name, path, level, nocycle)
    AS (SELECT 1 AS depth, CONCAT_WS('', LPAD(' ', (1 - 1) * 2), 'Node ', 1::TEXT) AS node_name, CONCAT_WS('', '/', 1::TEXT) AS path, 1 AS level, array_agg(1) OVER () AS nocycle
        WHERE 1 <= 5
    UNION ALL
    SELECT t.level + 1 AS depth, CONCAT_WS('', LPAD(' ', (t.level + 1 - 1) * 2), 'Node ', (t.level + 1)::TEXT) AS node_name, CONCAT_WS('', t.path, '/', (t.level + 1)::TEXT) AS path, t.level + 1 AS level, (t.nocycle || ARRAY(SELECT DISTINCT t.level + 1
            FROM aws_oracle_ext.dual
            WHERE t.level = t.level + 1)) AS nocycle
        FROM aws_oracle_ext.dual, t
        WHERE t.level + 1 <= 5 AND t.level <> 3 AND NOT (t.level + 1) = any(t.nocycle))
    SELECT depth, node_name, path
        FROM t
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  深さ: ', rec.depth, ', ノード: ', rec.node_name, ', パス: ', rec.path));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '4. 階層レベルと位置情報:');
    /* 階層レベルと位置情報を表示 */

    FOR rec IN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    WITH RECURSIVE t (level, root_level, is_leaf, path)
    AS (SELECT 1 AS level, 1 AS root_level, COALESCE((SELECT 0
            FROM aws_oracle_ext.dual AS t3
            WHERE 1 + 1 <= 5
            LIMIT 1), 1) AS is_leaf, CONCAT_WS('', '->', (1)::TEXT) AS path
    UNION ALL
    SELECT t.level + 1 AS level, t.root_level AS root_level, COALESCE((SELECT 0
            FROM aws_oracle_ext.dual AS t3
            WHERE t.level + 1 + 1 <= 5
            LIMIT 1), 1) AS is_leaf, CONCAT_WS('', t.path, '->', (t.level + 1)::TEXT) AS path
        FROM t
        WHERE t.level + 1 <= 5)
    SELECT level, root_level, is_leaf, path
        FROM t
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  レベル: ', rec.level, ', ルート: ', rec.root_level, ', リーフ?: ', rec.is_leaf, ', パス: ', rec.path));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '5. 複雑な階層構造（NOCYCLEの重要性）:');
    /* 複雑な階層構造を生成（循環参照を含む） */

    FOR rec IN
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    WITH hierarchy_data
    AS (SELECT 1 AS id, NULL AS parent_id, 'Root' AS name
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 2, 1, 'Child 1'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 3, 1, 'Child 2'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 4, 2, 'Grandchild 1'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 5, 3, 'Grandchild 2'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 6, 4, 'Great-Grandchild'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 7, 6, 'Circular Ref'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 8, 7, 'Deep Node'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 9, 8, 'Deeper Node'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 10, 9, 'Deepest Node'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 11, 10, 'Circular Back'
        FROM aws_oracle_ext.dual
    UNION ALL
    SELECT 12, 11, 'Final Node'
        FROM aws_oracle_ext.dual), hierarchy_query
    AS (SELECT 1 AS level, id AS id, parent_id AS parent_id, name AS name, array_agg(id) OVER () AS nocycle, CONCAT_WS('', ' -> ', (name)::TEXT) AS sys_connect_by_path, ARRAY[id] AS sibl_001_column0
        FROM hierarchy_data
        WHERE id = 1
    UNION ALL
    SELECT hq.level + 1 AS level, sq.id AS id, sq.parent_id AS parent_id, sq.name AS name, (hq.nocycle || ARRAY(SELECT DISTINCT id
            FROM hierarchy_data
            WHERE sq.id = parent_id)) AS nocycle, CONCAT_WS('', hq.sys_connect_by_path, ' -> ', (sq.name)::TEXT) AS sys_connect_by_path, (hq.sibl_001_column0 || sq.id)::NUMERIC[] AS sibl_001_column0
        FROM hierarchy_data AS sq
        INNER JOIN hierarchy_query AS hq
            ON hq.id = sq.parent_id
        WHERE NOT sq.id = ANY(hq.nocycle))
    SELECT level, LPAD(' ', (level - 1) * 2) || name AS hierarchy_name, sys_connect_by_path AS path, CASE
            WHEN id = ANY(nocycle) THEN 1
            ELSE 0
        END AS is_cycle
        FROM hierarchy_query
        ORDER BY sibl_001_column0
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    LOOP
        v_path :=
        CASE
            WHEN LENGTH(rec.path) > 80 THEN CONCAT_WS('', aws_oracle_ext.substr(rec.path, 1, 77), '...')
            ELSE rec.path
        END;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  レベル: ', rec.level, ', 名前: ', rec.hierarchy_name, ', 循環?: ', rec.is_cycle, ', パス: ', v_path));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '6. 数値の階乗計算:');
    /* 階乗の計算（1から10まで） */

    FOR rec IN
    WITH RECURSIVE t (n, factorial)
    AS (SELECT
        (1)::NUMERIC AS n, EXP(SUM(LN((1)::NUMERIC)) OVER (ORDER BY (1)::NUMERIC)) AS factorial
    UNION ALL
    SELECT
        (t.n + 1)::NUMERIC AS n, EXP(SUM(LN((t.level + 1)::NUMERIC)) OVER (ORDER BY (t.level + 1)::NUMERIC)) AS factorial
        FROM t
        WHERE (t.level + 1)::NUMERIC <= 10)
    SELECT
        n, factorial
        FROM t
    LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ', rec.n, '! = ', rec.factorial));
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== サンプル実行完了 =====');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0049_timestamp(IN p_date TIMESTAMP WITHOUT TIME ZONE, IN p_days_to_add DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_result_date TIMESTAMP(0) WITHOUT TIME ZONE;
    v_timestamp TIMESTAMP(6) WITHOUT TIME ZONE;
    v_timestamp_tz TIMESTAMP(6) WITH TIME ZONE;
    v_interval INTERVAL DAY TO SECOND;
    v_next_day TIMESTAMP(0) WITHOUT TIME ZONE;
    v_months_between DOUBLE PRECISION;
    v_add_months TIMESTAMP(0) WITHOUT TIME ZONE;
BEGIN
/* Oracle特有の日付処理 */
    v_result_date := p_date + (p_days_to_add::NUMERIC || ' days')::INTERVAL;
    /* 日付への数値加算（PostgreSQLでは異なる構文） */
    /* NEXT_DAY関数（PostgreSQLに直接対応する関数がない） */
    v_next_day := aws_oracle_ext.NEXT_DAY(p_date, 'MONDAY');
    /* Oracle特有のTRUNC関数の使用方法 */
    v_result_date := aws_oracle_ext.TRUNC(p_date, 'MM');
    /* 月の初日に切り捨て */
    /* Oracle特有のLAST_DAY関数 */
    v_result_date := aws_oracle_ext.LAST_DAY(p_date);
    /* 月の最終日 */
    /* MONTHS_BETWEEN関数（実装が異なる） */
    v_months_between := aws_oracle_ext.MONTHS_BETWEEN((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0), p_date);
    /* ADD_MONTHS関数 */
    v_add_months := aws_oracle_ext.ADD_MONTHS(p_date, 3);
    /* Oracle特有のタイムスタンプ処理 */
    v_timestamp := aws_oracle_ext.systimestamp();
    v_timestamp_tz := aws_oracle_ext.current_timestamp();
    /* Oracle特有のタイムゾーン変換 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    v_timestamp_tz := v_timestamp::TIMESTAMP AT TIME ZONE 'America/New_York';
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    /* Oracle特有のINTERVAL型の使用 */
    v_interval := concat_ws(' ', (p_days_to_add)::TEXT, 'DAY')::INTERVAL;
    v_result_date := p_date + v_interval;
    /* Oracle特有の日付フォーマット */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '日付: ', aws_oracle_ext.TO_CHAR(p_date, 'DD-MON-YYYY HH24:MI:SS')));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '結果日付: ', aws_oracle_ext.TO_CHAR(v_result_date, 'DD-MON-YYYY HH24:MI:SS')));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '次の月曜日: ', aws_oracle_ext.TO_CHAR(v_next_day, 'DD-MON-YYYY')));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '月の初日: ', aws_oracle_ext.TO_CHAR(aws_oracle_ext.TRUNC(p_date, 'MM'), 'DD-MON-YYYY')));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '月の最終日: ', aws_oracle_ext.TO_CHAR(aws_oracle_ext.LAST_DAY(p_date), 'DD-MON-YYYY')));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '月数の差: ', v_months_between));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '3ヶ月後: ', aws_oracle_ext.TO_CHAR(v_add_months, 'DD-MON-YYYY')));
    /* Oracle特有のタイムスタンプフォーマット */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '現在のタイムスタンプ: ', aws_oracle_ext.TO_CHAR(v_timestamp, 'DD-MON-YYYY HH24:MI:SS.FF3 TZR')));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ニューヨーク時間: ', aws_oracle_ext.TO_CHAR(v_timestamp_tz, 'DD-MON-YYYY HH24:MI:SS.FF3 TZR')));
    /* Oracle特有の日付抽出 */
    
    /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
    
    /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
    CALL DBMS_OUTPUT.PUT_LINE('年: ' || EXTRACT (YEAR FROM p_date::TIMESTAMP));
    /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '月: ', aws_oracle_ext.TO_CHAR(p_date, 'MM')));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '日: ', aws_oracle_ext.TO_CHAR(p_date, 'DD')));
    /* Oracle特有の日付計算 */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '日付差: ', ((EXTRACT (EPOCH FROM (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) - p_date) / 86400)::NUMERIC)));
    /* Oracle特有のTIMESTAMP WITH LOCAL TIME ZONE型 */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ローカルタイムゾーン: ', aws_oracle_ext.TO_CHAR(aws_oracle_ext.localtimestamp(), 'DD-MON-YYYY HH24:MI:SS.FF3')));
    /* Oracle特有のSYSDATE関数の使用 */

    IF p_date > (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0) THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => '未来の日付です');
    ELSE
        CALL aws_oracle_ext.dbms_output$put_line(a => '過去または現在の日付です');
    END IF;
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0051_get_error_message(IN p_error_code DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_error_message CHARACTER VARYING(4000);
BEGIN
/* 指定されたエラーコードのエラーメッセージを取得 */
    v_error_message := '';
    /* 結果を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーコード: ', p_error_code));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーメッセージ: ', v_error_message));
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'プロシージャ実行中にエラーが発生しました: ', ''));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0052_check_sqlcode_sample(IN p_id DOUBLE PRECISION, IN p_new_value DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_name CHARACTER VARYING(100);
    v_current_value DOUBLE PRECISION;
    v_status CHARACTER VARYING(20);
    v_error_code DOUBLE PRECISION;
    v_error_msg CHARACTER VARYING(4000);
    sql$rowcount BIGINT;
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '処理を開始します。ID: ', p_id));
    /* 最初のSQLを実行 */

    BEGIN
        SELECT
            name, value, status
            INTO STRICT v_name, v_current_value, v_status
            FROM schema_sample.t_0052
            WHERE id = p_id;
        /* EXCEPTION句の外でSQLCODEを参照 */
        v_error_code := '';
        v_error_msg := '';
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '最初のSQLの実行後のSQLCODE: ', v_error_code));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '最初のSQLの実行後のSQLERRM: ', v_error_msg));
        /* 取得したデータを表示 */
        CALL aws_oracle_ext.dbms_output$put_line(a => '取得したデータ:');
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  名前: ', v_name));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  現在の値: ', v_current_value));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  ステータス: ', v_status));
        EXCEPTION
            WHEN no_data_found THEN
                v_error_code := SQLSTATE;
                v_error_msg := SQLERRM;
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'データが見つかりません。SQLCODE: ', v_error_code));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーメッセージ: ', v_error_msg));
                RETURN;
    END;
    /* ステータスチェック */

    IF v_status = '非アクティブ' THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => '非アクティブのレコードは更新できません。');
        RETURN;
    END IF;
    /* 更新処理 */

    BEGIN
        UPDATE schema_sample.t_0052
        SET value = p_new_value, created_date = (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0)
            WHERE id = p_id;
        /* EXCEPTION句の外でSQLCODEを参照 */
        v_error_code := '';
        v_error_msg := '';
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '更新処理後のSQLCODE: ', v_error_code));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '更新処理後のSQLERRM: ', v_error_msg));
        /* 更新された行数を確認 */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount > 0 THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '更新が成功しました。新しい値: ', p_new_value));
        ELSE
            CALL aws_oracle_ext.dbms_output$put_line(a => '更新対象のレコードがありませんでした。');
        END IF;
        EXCEPTION
            WHEN others THEN
                v_error_code := SQLSTATE;
                v_error_msg := SQLERRM;
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '更新中にエラーが発生しました。SQLCODE: ', v_error_code));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーメッセージ: ', v_error_msg));
                /*
                [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
                ROLLBACK
                */
                RETURN;
    END;
    /* 存在しないテーブルにアクセスして意図的にエラーを発生させる */

    BEGIN
        EXECUTE 'SELECT COUNT(*) FROM non_existent_table';
        EXCEPTION
            WHEN others THEN
                v_error_code := SQLSTATE;
                v_error_msg := SQLERRM;
                CALL aws_oracle_ext.dbms_output$put_line(a => '存在しないテーブルへのアクセスでエラーが発生しました。');
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'SQLCODE: ', v_error_code));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'SQLERRM: ', v_error_msg));
    END;
    /* 最終的なSQLCODEの状態を確認 */
    v_error_code := '';
    v_error_msg := '';
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'プロシージャ終了時のSQLCODE: ', v_error_code));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'プロシージャ終了時のSQLERRM: ', v_error_msg));
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => '処理が完了しました。');
    EXCEPTION
        WHEN others THEN
            v_error_code := SQLSTATE;
            v_error_msg := SQLERRM;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '予期しないエラーが発生しました。SQLCODE: ', v_error_code));
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーメッセージ: ', v_error_msg));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0054_get_table_data(IN p_id DOUBLE PRECISION, OUT p_name TEXT, OUT p_value TEXT)
AS 
$BODY$
BEGIN
    p_name := schema_sample.sct_0054_get_table_name(p_id);
    p_value := aws_oracle_ext.TO_CHAR(schema_sample.sct_0054_get_table_value(p_id));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0055_update_from_subquery(IN p_id DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    sql$rowcount BIGINT;
BEGIN
/* 指定されたIDのレコードを更新 */
/* T_0055_2テーブルから最大値と最小値を取得して更新 */
    UPDATE schema_sample.t_0055_1
    SET (c1, c2) = (SELECT
        MAX(c1), MIN(c1)
        FROM schema_sample.t_0055_2)
        WHERE id = p_id;
    /* 更新された行数を出力 */
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '更新された行数: ', sql$rowcount));
    COMMIT;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0056_savepoint_demo(IN p_success_all BOOLEAN DEFAULT FALSE)
AS 
$BODY$
DECLARE
    v_count DOUBLE PRECISION;
BEGIN
/* 処理開始 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '処理を開始します。');
    /* 最初のデータ挿入 */
    INSERT INTO schema_sample.t_0056 (id, name, value, status)
    VALUES (4, 'アイテム4', 400, 'アクティブ');
    CALL aws_oracle_ext.dbms_output$put_line(a => 'アイテム4を挿入しました。');
    /* 最初のセーブポイントを設定 */
    
    /*
    [5611 - Severity CRITICAL - PostgreSQL doesn't support SAVEPOINT and ROLLBACK TO SAVEPOINT inside routines. Convert your source code manually.]
    SAVEPOINT sp_after_first_insert
    */
    /* 2番目のデータ挿入 */
    INSERT INTO schema_sample.t_0056 (id, name, value, status)
    VALUES (5, 'アイテム5', 500, 'アクティブ');
    CALL aws_oracle_ext.dbms_output$put_line(a => 'アイテム5を挿入しました。');
    /* 2番目のセーブポイントを設定 */
    
    /*
    [5611 - Severity CRITICAL - PostgreSQL doesn't support SAVEPOINT and ROLLBACK TO SAVEPOINT inside routines. Convert your source code manually.]
    SAVEPOINT sp_after_second_insert
    */
    /* 意図的にエラーを発生させる可能性のある処理 */
    BEGIN
    /* 主キー違反を発生させる（IDが重複） */
        INSERT INTO schema_sample.t_0056 (id, name, value, status)
        VALUES (5, 'アイテム5（重複）', 550, 'アクティブ');
        CALL aws_oracle_ext.dbms_output$put_line(a => 'アイテム5（重複）を挿入しました。');
        EXCEPTION
            WHEN unique_violation THEN
                CALL aws_oracle_ext.dbms_output$put_line(a => 'エラー: 主キー違反が発生しました。');

                IF p_success_all THEN
                    /* 2番目のセーブポイントまでロールバック */
                    CALL aws_oracle_ext.dbms_output$put_line(a => '2番目のセーブポイントまでロールバックします。');
                    /*
                    [5611 - Severity CRITICAL - PostgreSQL doesn't support SAVEPOINT and ROLLBACK TO SAVEPOINT inside routines. Convert your source code manually., 5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
                    ROLLBACK TO SAVEPOINT sp_after_second_insert
                    */
                ELSE
                    /* 最初のセーブポイントまでロールバック */
                    CALL aws_oracle_ext.dbms_output$put_line(a => '最初のセーブポイントまでロールバックします。');
                    /*
                    [5611 - Severity CRITICAL - PostgreSQL doesn't support SAVEPOINT and ROLLBACK TO SAVEPOINT inside routines. Convert your source code manually., 5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
                    ROLLBACK TO SAVEPOINT sp_after_first_insert
                    */
                END IF;
    END;
    /* 最後のデータ挿入 */
    INSERT INTO schema_sample.t_0056 (id, name, value, status)
    VALUES (6, 'アイテム6', 600, 'アクティブ');
    CALL aws_oracle_ext.dbms_output$put_line(a => 'アイテム6を挿入しました。');
    /* 現在のデータ数を確認 */
    SELECT
        COUNT(*)
        INTO STRICT v_count
        FROM schema_sample.t_0056;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '現在のデータ数: ', v_count));
    /* コミット */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'すべての変更をコミットしました。');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '予期しないエラーが発生しました: ', SQLERRM));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            CALL aws_oracle_ext.dbms_output$put_line(a => 'すべての変更をロールバックしました。');
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0057_extract_patterns()
AS 
$BODY$
/* カーソルの定義 */
DECLARE
    c_strings CURSOR FOR
    SELECT
        id, input_string
        FROM schema_sample.t_0057_strings;
    c_strings$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    /* 抽出したパターンを格納する変数 */
    v_phone CHARACTER VARYING(20);
    v_email CHARACTER VARYING(100);
    v_date CHARACTER VARYING(20);
    v_code CHARACTER VARYING(20);
    v_price CHARACTER VARYING(20);
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== パターン抽出結果 =====');
    /* 各文字列からパターンを抽出 */

    FOR rec IN c_strings LOOP
        /* 電話番号を抽出 */
        v_phone := regexp_substr((rec.input_string)::TEXT, (E'\\d{2,4}-\\d{2,4}-\\d{4}')::TEXT);
        /* メールアドレスを抽出 */
        v_email := regexp_substr((rec.input_string)::TEXT, (E'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}')::TEXT);
        /* 日付を抽出 (YYYY/MM/DD形式) */
        v_date := regexp_substr((rec.input_string)::TEXT, (E'\\d{4}/\\d{2}/\\d{2}')::TEXT);

        IF v_date IS NULL THEN
            /* 年月日形式も試す */
            v_date := regexp_substr((rec.input_string)::TEXT, (E'\\d{4}年\\d{1,2}月\\d{1,2}日')::TEXT);
        END IF;
        /* 商品コードを抽出 (XXX-XXX-XXX形式) */
        v_code := regexp_substr((rec.input_string)::TEXT, (E'[A-Z]+-\\d+-[A-Z]+')::TEXT);
        /* 価格を抽出 */
        v_price := regexp_substr((rec.input_string)::TEXT, (E'\\d{1,3}(,\\d{3})*円')::TEXT);
        /* 結果を出力 */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', rec.id, ' の抽出結果:'));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  入力文字列: ', rec.input_string));

        IF v_phone IS NOT NULL THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  電話番号: ', v_phone));
        END IF;

        IF v_email IS NOT NULL THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  メールアドレス: ', v_email));
        END IF;

        IF v_date IS NOT NULL THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  日付: ', v_date));
        END IF;

        IF v_code IS NOT NULL THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  商品コード: ', v_code));
        END IF;

        IF v_price IS NOT NULL THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  価格: ', v_price));
        END IF;
        CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    END LOOP;
    CALL aws_oracle_ext.dbms_output$put_line(a => 'パターン抽出が完了しました。');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0057_string_operations()
AS 
$BODY$
/* カーソルの定義 */
DECLARE
    c_strings CURSOR FOR
    SELECT
        id, input_string
        FROM schema_sample.t_0057_strings;
    c_strings$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    v_processed CHARACTER VARYING(200);
BEGIN
/* 各文字列を処理 */
    FOR rec IN c_strings LOOP
        v_processed := rec.input_string;
        /* 1. 電話番号のフォーマットを変更 (03-1234-5678 → 03(1234)5678) */
        v_processed := regexp_replace((v_processed)::TEXT, (E'(\\d{2,4})-(\\d{2,4})-(\\d{4})')::TEXT, coalesce((E'\\1(\\2)\\3')::TEXT, ''), (1)::INTEGER, (0)::INTEGER);
        /* 2. 日付のフォーマットを変更 (2023/07/15 → 2023-07-15) */
        v_processed := regexp_replace((v_processed)::TEXT, (E'(\\d{4})/(\\d{2})/(\\d{2})')::TEXT, coalesce((E'\\1-\\2-\\3')::TEXT, ''), (1)::INTEGER, (0)::INTEGER);
        /* 3. URLの前に「リンク:」を追加 */
        v_processed := regexp_replace((v_processed)::TEXT, (E'(https?://[^\\s,、]+)')::TEXT, coalesce((E'リンク: \\1')::TEXT, ''), (1)::INTEGER, (0)::INTEGER);
        /* 4. 金額表記を統一 (12,345円 → ￥12,345) */
        v_processed := regexp_replace((v_processed)::TEXT, (E'(\\d{1,3}(,\\d{3})*)(円)')::TEXT, coalesce((E'￥\\1')::TEXT, ''), (1)::INTEGER, (0)::INTEGER);
        /* 5. 年月日表記を西暦表記に変更 (2023年7月4日 → 2023-07-04) */
        v_processed := regexp_replace((v_processed)::TEXT, (E'(\\d{4})年(\\d{1,2})月(\\d{1,2})日')::TEXT, coalesce((CONCAT_WS('', E'\\1-', LPAD(regexp_substr((v_processed)::TEXT, (E'(\\d{4})年(\\d{1,2})月')::TEXT, (1)::INTEGER, (1)::INTEGER, NULL::TEXT, (2)::INTEGER), 2, '0'), '-', LPAD(regexp_substr((v_processed)::TEXT, (E'月(\\d{1,2})日')::TEXT, (1)::INTEGER, (1)::INTEGER, NULL::TEXT, (1)::INTEGER), 2, '0'))::TEXT)::TEXT, ''), (1)::INTEGER, (0)::INTEGER);
        /* 処理結果を更新 */
        UPDATE schema_sample.t_0057_strings
        SET processed_string = v_processed
            WHERE id = rec.id;
        /* 結果を出力 */
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', rec.id));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  入力: ', rec.input_string));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '  出力: ', v_processed));
        CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    END LOOP;
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => '文字列処理が完了しました。');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0058_get_transaction_id()
AS 
$BODY$
DECLARE
    v_trans_id CHARACTER VARYING(100);
BEGIN
/* 現在のトランザクションIDを取得 */
    v_trans_id := txid_current()::TEXT;
    /* トランザクションIDを表示 */

    IF v_trans_id IS NOT NULL THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '現在のトランザクションID: ', v_trans_id));
    ELSE
        CALL aws_oracle_ext.dbms_output$put_line(a => 'アクティブなトランザクションはありません');
        /* トランザクションを開始するためのダミー操作 */
        EXECUTE 'UPDATE dual SET dummy = DUMMY WHERE rownum = 0';
        /* 再度トランザクションIDを取得 */
        v_trans_id := txid_current()::TEXT;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '新しいトランザクションID: ', v_trans_id));
    END IF;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0059_dynamic_sql_with_bind(IN p_expression TEXT, IN p_bind_value TEXT)
AS 
$BODY$
DECLARE
    v_cursor_id NUMERIC(38);
    v_rows_processed NUMERIC(38);
    v_sql CHARACTER VARYING(4000);
    v_result CHARACTER VARYING(4000);
BEGIN
/* 動的SQLの文字列を構築（バインド変数を使用） */
    v_sql := CONCAT_WS('', 'SELECT  ', p_expression, ' WHERE $1 IS NOT NULL');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '実行するSQL: ', v_sql));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'バインド値: ', p_bind_value));
    /* カーソルをオープン */
    v_cursor_id := aws_oracle_ext.dbms_sql$open_cursor();
    /* SQLをパース */
    PERFORM aws_oracle_ext.dbms_sql$parse((v_cursor_id)::INTEGER, (v_sql)::TEXT);
    /* バインド変数を設定 */
    PERFORM aws_oracle_ext.dbms_sql$bind_variable((v_cursor_id)::INTEGER, ('$1|:bind_param')::VARCHAR, p_bind_value);
    /* 出力変数を定義 */
    PERFORM aws_oracle_ext.dbms_sql$define_column((v_cursor_id)::INTEGER, (1)::INTEGER, v_result, (4000)::INTEGER);
    /* SQLを実行 */
    v_rows_processed := aws_oracle_ext.dbms_sql$execute((v_cursor_id)::INTEGER);
    /* 結果を取得 */

    IF aws_oracle_ext.dbms_sql$fetch_rows((v_cursor_id)::INTEGER) > 0 THEN
        SELECT
            p_column_val
            INTO v_result
            FROM aws_oracle_ext.dbms_sql$column_value((v_cursor_id)::INTEGER, (1)::INTEGER, v_result);
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '計算結果: ', v_result));
    END IF;
    /* カーソルをクローズ */
    v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
    EXCEPTION
        WHEN others THEN
            /* エラーが発生した場合はカーソルをクローズ */
            IF aws_oracle_ext.dbms_sql$is_open((v_cursor_id)::INTEGER) THEN
                v_cursor_id := aws_oracle_ext.dbms_sql$close_cursor((v_cursor_id)::NUMERIC);
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0060_collection_types_demo()
AS 
$BODY$
/* PL/SQL表（INDEX BY表）の定義 */
DECLARE
    aws_oracle_ext$array_id$temporary BIGINT;
    /* Nested Tableの定義 */
    /* 変数宣言 */
    v_idx_table VARCHAR(100) := 'v_idx_table';
    v_nested_table schema_sample.sct_0060_collection_types_demo$nested_table_type := ARRAY[]::schema_sample.sct_0060_collection_types_demo$nested_table_type;
BEGIN
/* PL/SQL表にデータを格納 */
    aws_oracle_ext$array_id$temporary := aws_oracle_ext.array$create_array(p_array_name => 'v_idx_table', p_procedure_name => 'schema_sample.sct_0060_collection_types_demo');
    PERFORM aws_oracle_ext.array$add_fields_to_array(p_array_id => aws_oracle_ext$array_id$temporary, p_fields => '[{"":"CHARACTER VARYING(100)"}]');
    PERFORM aws_oracle_ext.array$create_storage_table(p_array_name => 'v_idx_table', p_procedure_name => 'schema_sample.sct_0060_collection_types_demo', p_cast_type_name => 'schema_sample.sct_0060_collection_types_demo$idx_table_type$c', pWithData => FALSE);
    PERFORM aws_oracle_ext.array$set_value(p_array_path => 'v_idx_table[1]', p_procedure_name => 'schema_sample.sct_0060_collection_types_demo', p_value => '東京'::CHARACTER VARYING(100));
    PERFORM aws_oracle_ext.array$set_value(p_array_path => 'v_idx_table[2]', p_procedure_name => 'schema_sample.sct_0060_collection_types_demo', p_value => '大阪'::CHARACTER VARYING(100));
    PERFORM aws_oracle_ext.array$set_value(p_array_path => 'v_idx_table[3]', p_procedure_name => 'schema_sample.sct_0060_collection_types_demo', p_value => '名古屋'::CHARACTER VARYING(100));
    PERFORM aws_oracle_ext.array$set_value(p_array_path => 'v_idx_table[10]', p_procedure_name => 'schema_sample.sct_0060_collection_types_demo', p_value => '福岡'::CHARACTER VARYING(100));
    /* 非連続インデックスも可能 */
    /* Nested Tableにデータを格納 */
    v_nested_table := aws_oracle_ext.collection_extend(pcollection => v_nested_table, pcount => 4);
    /* 領域を確保 */
    v_nested_table := aws_oracle_ext.collection_element_set(pcollection => v_nested_table, ppath => ARRAY[1]::NUMERIC(10, 0)[], pval => '北海道'::TEXT);
    v_nested_table := aws_oracle_ext.collection_element_set(pcollection => v_nested_table, ppath => ARRAY[2]::NUMERIC(10, 0)[], pval => '沖縄'::TEXT);
    v_nested_table := aws_oracle_ext.collection_element_set(pcollection => v_nested_table, ppath => ARRAY[3]::NUMERIC(10, 0)[], pval => '京都'::TEXT);
    v_nested_table := aws_oracle_ext.collection_element_set(pcollection => v_nested_table, ppath => ARRAY[4]::NUMERIC(10, 0)[], pval => '広島'::TEXT);
    /* PL/SQL表の内容を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'PL/SQL表（INDEX BY表）の内容:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '-------------------');

    FOR i IN aws_oracle_ext.array$first('v_idx_table', 'schema_sample.sct_0060_collection_types_demo', NULL::BIGINT)..aws_oracle_ext.array$last('v_idx_table', 'schema_sample.sct_0060_collection_types_demo', NULL::BIGINT) LOOP
        IF aws_oracle_ext.array$exists('v_idx_table', i::TEXT, 'schema_sample.sct_0060_collection_types_demo') THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'インデックス ', i, ': ', (aws_oracle_ext.array$get_value(p_array_value_path => 'v_idx_table[' || i || ']', p_procedure_name => 'schema_sample.sct_0060_collection_types_demo', p_value_datatype => NULL::schema_sample.sct_0060_collection_types_demo$idx_table_type$c)).column_value));
        END IF;
    END LOOP;
    /* Nested Tableの内容を表示 */
    CALL aws_oracle_ext.dbms_output$put_line(a => '-------------------');
    CALL aws_oracle_ext.dbms_output$put_line(a => 'Nested Tableの内容:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '-------------------');

    FOR i IN 1..COALESCE(array_length(v_nested_table, 1), 0) LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'インデックス ', i, ': ', (v_nested_table)[i]));
    END LOOP;
    PERFORM aws_oracle_ext.array$clear_procedure('schema_sample.sct_0060_collection_types_demo');
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0061_multiple_bulk_collect(IN p_department_id DOUBLE PRECISION DEFAULT NULL)
AS 
$BODY$
/* 複数のコレクション型を定義 */
DECLARE
    /* 複数のコレクション変数を宣言 */
    v_emp_ids schema_sample.sct_0061_multiple_bulk_collect$t_emp_id_table;
    v_first_names schema_sample.sct_0061_multiple_bulk_collect$t_first_name_table;
    v_last_names schema_sample.sct_0061_multiple_bulk_collect$t_last_name_table;
    v_emails schema_sample.sct_0061_multiple_bulk_collect$t_email_table;
    v_salaries schema_sample.sct_0061_multiple_bulk_collect$t_salary_table;
    v_dept_names schema_sample.sct_0061_multiple_bulk_collect$t_dept_name_table;
    /* 処理した行数を格納する変数 */
    v_row_count INTEGER;
BEGIN
/* 複数のコレクション変数に対してBULK COLLECT INTO */
/* これがPostgreSQLに変換する際にエラーとなる部分 */
    SELECT
        ARRAY_AGG(blk.employee_id), ARRAY_AGG(blk.first_name), ARRAY_AGG(blk.last_name), ARRAY_AGG(blk.email), ARRAY_AGG(blk.salary), ARRAY_AGG(blk.department_name)
        INTO v_emp_ids, v_first_names, v_last_names, v_emails, v_salaries, v_dept_names
        FROM (SELECT
            e.employee_id AS employee_id, e.first_name AS first_name, e.last_name AS last_name, e.email AS email, e.salary AS salary, d.department_name AS department_name
            FROM schema_sample.t_0061_employees AS e
            JOIN schema_sample.t_0061_departments AS d
                ON e.department_id = d.department_id
            WHERE (p_department_id IS NULL OR e.department_id = p_department_id)
            ORDER BY e.employee_id) AS blk
        WHERE (p_department_id IS NULL OR e.department_id = p_department_id);
    v_row_count := COALESCE(array_length(v_emp_ids, 1), 0);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '取得した従業員数: ', v_row_count));
    /* 結果を表示 */

    FOR i IN 1..v_row_count LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', (v_emp_ids)[i], ', 名前: ', (v_first_names)[i], ' ', (v_last_names)[i], ', メール: ', (v_emails)[i], ', 給与: ', (v_salaries)[i], ', 部署: ', (v_dept_names)[i]));
    END LOOP;
    /* 給与の合計と平均を計算 */

    DECLARE
        v_total_salary DOUBLE PRECISION := 0;
        v_avg_salary DOUBLE PRECISION;
    BEGIN
        FOR i IN 1..COALESCE(array_length(v_salaries, 1), 0) LOOP
            v_total_salary := v_total_salary + (v_salaries)[i];
        END LOOP;

        IF COALESCE(array_length(v_salaries, 1), 0) > 0 THEN
            v_avg_salary := v_total_salary / COALESCE(array_length(v_salaries, 1), 0)::NUMERIC;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '給与合計: ', v_total_salary));
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '平均給与: ', v_avg_salary));
        END IF;
    END;
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0061_nested_bulk_collect()
AS 
$BODY$
/* コレクション型を定義 */
DECLARE
    /* 部門情報用のコレクション */
    v_dept_ids schema_sample.sct_0061_nested_bulk_collect$t_dept_id_table;
    v_dept_names schema_sample.sct_0061_nested_bulk_collect$t_dept_name_table;
    /* 従業員情報用のコレクション */
    v_emp_ids schema_sample.sct_0061_nested_bulk_collect$t_emp_id_table;
    v_emp_names schema_sample.sct_0061_nested_bulk_collect$t_emp_name_table;
    v_emp_salaries schema_sample.sct_0061_nested_bulk_collect$t_emp_salary_table;
    /* 部門ごとの従業員数 */
    v_emp_count INTEGER;
BEGIN
/* 部門情報を取得 */
    SELECT
        ARRAY_AGG(blk.department_id), ARRAY_AGG(blk.department_name)
        INTO v_dept_ids, v_dept_names
        FROM (SELECT
            department_id AS department_id, department_name AS department_name
            FROM schema_sample.t_0061_departments
            ORDER BY department_id) AS blk;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '部門数: ', COALESCE(array_length(v_dept_ids, 1), 0)));
    /* 各部門の従業員情報を取得 */

    FOR i IN 1..COALESCE(array_length(v_dept_ids, 1), 0) LOOP
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '===== 部門: ', (v_dept_names)[i], ' ====='));
        /* 部門ごとに従業員情報をBULK COLLECT */
        SELECT
            ARRAY_AGG(blk.employee_id), ARRAY_AGG(blk.CONCAT_WS), ARRAY_AGG(blk.salary)
            INTO v_emp_ids, v_emp_names, v_emp_salaries
            FROM (SELECT
                e.employee_id AS employee_id, CONCAT_WS('', e.first_name, ' ', e.last_name), e.salary AS salary
                FROM schema_sample.t_0061_employees AS e
                WHERE e.department_id = (v_dept_ids)[i]
                ORDER BY e.employee_id) AS blk
            WHERE e.department_id = (v_dept_ids)[i];
        v_emp_count := COALESCE(array_length(v_emp_ids, 1), 0);
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '従業員数: ', v_emp_count));
        /* 従業員情報を表示 */

        FOR j IN 1..v_emp_count LOOP
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', (v_emp_ids)[j], ', 名前: ', (v_emp_names)[j], ', 給与: ', (v_emp_salaries)[j]));
        END LOOP;
        /* 部門の給与統計 */

        IF v_emp_count > 0 THEN
            DECLARE
                v_total_salary DOUBLE PRECISION := 0;
                v_max_salary DOUBLE PRECISION := 0;
                v_min_salary DOUBLE PRECISION := 999999;
            BEGIN
                FOR j IN 1..v_emp_count LOOP
                    v_total_salary := v_total_salary + (v_emp_salaries)[j];
                    v_max_salary := aws_oracle_ext.greatest(v_max_salary::DOUBLE PRECISION, (v_emp_salaries)[j]::DOUBLE PRECISION);
                    v_min_salary := aws_oracle_ext.least(v_min_salary::DOUBLE PRECISION, (v_emp_salaries)[j]::DOUBLE PRECISION);
                END LOOP;
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '部門給与合計: ', v_total_salary));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '部門平均給与: ', (v_total_salary / v_emp_count)));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '部門最高給与: ', v_max_salary));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '部門最低給与: ', v_min_salary));
            END;
        END IF;
        CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    END LOOP;
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0062_process_data(IN p_row_count DOUBLE PRECISION DEFAULT 10, IN p_prefix TEXT DEFAULT 'Item-', IN p_action TEXT DEFAULT 'DISPLAY')
AS 
$BODY$
/* 'DISPLAY', 'SUMMARIZE', 'EXPORT' */
/* 変数宣言 */
DECLARE
    v_total_count DOUBLE PRECISION := 0;
    v_sum_ids DOUBLE PRECISION := 0;
    v_dummy CHARACTER VARYING(1);
    data_rec RECORD;
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => 'データ処理を開始します...');
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '行数: ', p_row_count));
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'プレフィックス: ', p_prefix));
    /* DUAL テーブルを使用して処理開始時刻を取得 */
    SELECT 'X'
        INTO STRICT v_dummy;
    /* アクションに基づいて処理 */
    CASE UPPER(p_action)
        WHEN 'DISPLAY' THEN
            /* データを表示 */
            CALL aws_oracle_ext.dbms_output$put_line(a => '-----------------------------------');
            CALL aws_oracle_ext.dbms_output$put_line(a => 'ID  | 値                 | 日時');
            CALL aws_oracle_ext.dbms_output$put_line(a => '-----------------------------------');
            /* パイプライン化されたテーブル関数を使用 */
            
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            FOR data_rec IN
            (SELECT (t).*
                FROM aws_oracle_ext.table(pVal => schema_sample.sct_0062_generate_data(p_row_count, p_prefix), pValType => 'NESTED', pTypeToCast => 'function0_return_type$c')
                    AS (t function0_return_type$c))
            LOOP
                RAISE DEBUG USING MESSAGE = CONCAT_WS('', LPAD((data_rec.id)::TEXT, TRUNC((3)::NUMERIC)::INTEGER), ' | ', RPAD((data_rec.value)::TEXT, TRUNC((20)::NUMERIC)::INTEGER), ' | ', aws_oracle_ext.to_char(data_rec.calc_date, 'YYYY-MM-DD HH24:MI:SS'));
                v_total_count := v_total_count + 1;
                v_sum_ids := v_sum_ids + data_rec.id;
            END LOOP;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            CALL aws_oracle_ext.dbms_output$put_line(a => '-----------------------------------');
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '処理された行数: ', v_total_count));
        WHEN 'SUMMARIZE' THEN
            /* データの要約を表示 */
            CALL aws_oracle_ext.dbms_output$put_line(a => 'データ要約を生成中...');
            /* パイプライン化されたテーブル関数を使用してデータを集計 */
            
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            FOR data_rec IN
            (SELECT (t).*
                FROM aws_oracle_ext.table(pVal => schema_sample.sct_0062_generate_data(p_row_count, p_prefix), pValType => 'NESTED', pTypeToCast => 'function0_return_type$c')
                    AS (t function0_return_type$c))
            LOOP
                v_total_count := v_total_count + 1;
                v_sum_ids := v_sum_ids + data_rec.id;
            END LOOP;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            /* DUAL テーブルを使用して平均を計算 */
            DECLARE
                v_average DOUBLE PRECISION;
                data_rec RECORD;
            BEGIN
                SELECT
                        CASE
                            WHEN v_total_count > 0 THEN v_sum_ids / v_total_count
                            ELSE 0
                        END
                    INTO STRICT v_average;
                CALL aws_oracle_ext.dbms_output$put_line(a => '-----------------------------------');
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '総行数: ', v_total_count));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID合計: ', v_sum_ids));
                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID平均: ', aws_oracle_ext.TO_CHAR(v_average, '999.99')));
            END;
        WHEN 'EXPORT' THEN
            /* データのエクスポート（シミュレーション） */
            CALL aws_oracle_ext.dbms_output$put_line(a => 'データエクスポートをシミュレート中...');
            /* エクスポートヘッダー */
            CALL aws_oracle_ext.dbms_output$put_line(a => 'ID,VALUE,CALC_DATE');
            /* パイプライン化されたテーブル関数を使用してデータをエクスポート */
            
            /* [5444 - Severity INFO - This conversion uses machine learning models that generate predictions based on patterns in data. Output generated by a machine learning model is probabilistic and should be evaluated for accuracy as appropriate for your use case, including by employing human review of such output.] */
            
            /* vvv ---- Beginning of statement generated using GenAI. ---- vvv */
            FOR data_rec IN
            (SELECT (t).*
                FROM aws_oracle_ext.table(pVal => schema_sample.sct_0062_generate_data(p_row_count, p_prefix), pValType => 'NESTEDREC', pTypeToCast => 'function0_return_type')
                    AS (t function0_return_type))
            LOOP
                /* CSV形式で出力 */
                RAISE DEBUG USING MESSAGE = CONCAT_WS('', data_rec.id, ',"', data_rec.value, '",', aws_oracle_ext.to_char(data_rec.calc_date, 'YYYY-MM-DD HH24:MI:SS'));
                v_total_count := v_total_count + 1;
            END LOOP;
            /* ^^^ ---- End of statement generated using GenAI. ---- ^^^ */
            CALL aws_oracle_ext.dbms_output$put_line(a => '-----------------------------------');
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', v_total_count, ' 行がエクスポートされました'));
        ELSE
            /* DUAL テーブルを使用してエラーメッセージを生成 */
            SELECT 'X'
                INTO STRICT v_dummy;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '不明なアクション: ', p_action));
            CALL aws_oracle_ext.dbms_output$put_line(a => '有効なアクション: DISPLAY, SUMMARIZE, EXPORT');
    END CASE;
    /* DUAL テーブルを使用して処理終了時刻を取得 */

    DECLARE
        v_end_time CHARACTER VARYING(30);
    BEGIN
        SELECT aws_oracle_ext.TO_CHAR((CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0), 'YYYY-MM-DD HH24:MI:SS')
            INTO STRICT v_end_time;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '処理が完了しました。時刻: ', v_end_time));
    END;
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0068_insert_user(IN p_user_id DOUBLE PRECISION, IN p_username TEXT, IN p_email TEXT)
AS 
$BODY$
DECLARE
    v_error_code DOUBLE PRECISION;
    v_error_msg CHARACTER VARYING(4000);
BEGIN
/* ユーザーの挿入を試みる */
    INSERT INTO schema_sample.t_0068_users (user_id, username, email)
    VALUES (p_user_id, p_username, p_email);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ユーザーを正常に追加しました。ID: ', p_user_id));
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    EXCEPTION
        WHEN others THEN
            /* SQLCODEを数値型として取得 */
            v_error_code := SQLSTATE;
            v_error_msg := SQLERRM;
            /* エラーコードに基づいて処理 */
            CASE v_error_code
                WHEN - 1 THEN
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '一意制約違反が発生しました。エラーコード: ', v_error_code));
                    /* ユーザー名とメールアドレスのどちらが重複しているかを確認 */

                    BEGIN
                        SELECT
                            1
                            INTO STRICT v_error_code
                            FROM schema_sample.t_0068_users
                            WHERE username = p_username;
                        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ユーザー名 "', p_username, '" は既に使用されています。'));
                        EXCEPTION
                            WHEN no_data_found THEN
                                CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'メールアドレス "', p_email, '" は既に使用されています。'));
                    END;
                WHEN - 2291 THEN
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '親キーが存在しません。エラーコード: ', v_error_code));
                WHEN - 12899 THEN
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '値が列の長さを超えています。エラーコード: ', v_error_code));
                ELSE
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '予期しないエラーが発生しました。エラーコード: ', v_error_code));
            END CASE;
            /* エラーログに記録 */
            INSERT INTO schema_sample.t_0068_error_log (log_id, error_code, error_message, procedure_name)
            VALUES (nextval('schema_sample.t_0068_log_seq'), v_error_code, v_error_msg, 'SCT_0068_INSERT_USER');
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            COMMIT
            */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0068_test_error_codes()
AS 
$BODY$
DECLARE
    v_user_id DOUBLE PRECISION;
    v_result DOUBLE PRECISION;
    v_error_code DOUBLE PRECISION;
    v_error_msg CHARACTER VARYING(4000);
BEGIN
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== SQLCODEの数値比較テスト =====');
    /* テスト1: 存在しないユーザーIDを検索 */

    BEGIN
        SELECT
            user_id
            INTO STRICT v_user_id
            FROM schema_sample.t_0068_users
            WHERE user_id = 999;
        CALL aws_oracle_ext.dbms_output$put_line(a => 'ユーザーID 999 が見つかりました。');
        EXCEPTION
            WHEN others THEN
                v_error_code := SQLSTATE;
                /* SQLCODEを数値として比較 */

                IF v_error_code = - 1403 THEN
                    /* NO_DATA_FOUND */
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'データが見つかりません。エラーコード: ', v_error_code));
                ELSE
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'その他のエラー。エラーコード: ', v_error_code));
                END IF;
    END;
    /* テスト2: 存在しないテーブルにアクセス */

    BEGIN
        EXECUTE 'SELECT COUNT(*) FROM non_existent_table';
        CALL aws_oracle_ext.dbms_output$put_line(a => 'テーブルが存在します。');
        EXCEPTION
            WHEN others THEN
                v_error_code := SQLSTATE;
                /* SQLCODEを数値として比較 */

                IF v_error_code = - 942 THEN
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'テーブルが存在しません。エラーコード: ', v_error_code));
                ELSIF v_error_code < - 1000 THEN
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '深刻なエラーが発生しました。エラーコード: ', v_error_code));
                ELSE
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'その他のエラー。エラーコード: ', v_error_code));
                END IF;
    END;
    /* テスト3: 算術演算エラー */

    BEGIN
        v_result := 100::NUMERIC / 0::NUMERIC;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '計算結果: ', v_result));
        EXCEPTION
            WHEN others THEN
                v_error_code := SQLSTATE;
                /* SQLCODEを数値として比較 */

                IF v_error_code = - 1476 THEN
                    /* ORA-01476: 除数にゼロが指定されました */
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ゼロ除算エラー。エラーコード: ', v_error_code));
                ELSE
                    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'その他のエラー。エラーコード: ', v_error_code));
                END IF;
    END;
    /* エラーコードの範囲チェック */
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => '===== エラーコードの範囲チェック =====');

    FOR i IN 1..3 LOOP
        BEGIN
            CASE i
                WHEN 1 THEN
                    /* 存在しないテーブル */
                    EXECUTE 'SELECT * FROM no_such_table';
                WHEN 2 THEN
                    /* ゼロ除算 */
                    v_result := 1::NUMERIC / 0::NUMERIC;
                WHEN 3 THEN
                    /* 構文エラー */
                    EXECUTE 'SELECT * FORM dual';
            END CASE;
            EXCEPTION
                WHEN others THEN
                    v_error_code := SQLSTATE;
                    v_error_msg := SQLERRM;
                    /* エラーコードの範囲をチェック */

                    IF v_error_code BETWEEN - 1000 AND - 900 THEN
                        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '一般的なエラー: ', v_error_code, ' - ', v_error_msg));
                    ELSIF v_error_code < - 1000 THEN
                        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '特定のエラー: ', v_error_code, ' - ', v_error_msg));
                    ELSIF v_error_code = 0 THEN
                        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '成功: ', v_error_code, ' - ', v_error_msg));
                    ELSIF v_error_code > 0 THEN
                        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '警告: ', v_error_code, ' - ', v_error_msg));
                    END IF;
                    /* エラーログに記録 */
                    INSERT INTO schema_sample.t_0068_error_log (log_id, error_code, error_message, procedure_name)
                    VALUES (nextval('schema_sample.t_0068_log_seq'), v_error_code, v_error_msg, 'SCT_0068_TEST_ERROR_CODES');
        END;
    END LOOP;
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => 'すべてのテストが完了しました。');
    EXCEPTION
        WHEN others THEN
            v_error_code := SQLSTATE;
            v_error_msg := SQLERRM;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '予期しないエラーが発生しました。エラーコード: ', v_error_code, ', メッセージ: ', v_error_msg));
            /* エラーログに記録 */
            INSERT INTO schema_sample.t_0068_error_log (log_id, error_code, error_message, procedure_name)
            VALUES (nextval('schema_sample.t_0068_log_seq'), v_error_code, v_error_msg, 'SCT_0068_TEST_ERROR_CODES');
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            COMMIT
            */
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0069_main_procedure(IN p_id DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_cursor REFCURSOR;
    v_cursor$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    v_id schema_sample.t_0069.id%TYPE;
    v_name schema_sample.t_0069.name%TYPE;
    v_value schema_sample.t_0069.value%TYPE;
    v_date schema_sample.t_0069.created_date%TYPE;
    v_cursor$FETCH RECORD;
BEGIN
/* カーソル変数を渡すプロシージャを呼び出し */
    SELECT
        NULL::DOUBLE PRECISION AS v_id, NULL::CHARACTER VARYING(100) AS v_name, NULL::DOUBLE PRECISION AS v_value, NULL::TIMESTAMP(0) WITHOUT TIME ZONE AS v_date
        INTO v_cursor$FETCH;
    CALL schema_sample.sct_0069_process_with_cursor(p_id, v_cursor);
    /* カーソルからデータを取得 */
    FETCH v_cursor INTO v_cursor$FETCH.v_id, v_cursor$FETCH.v_name, v_cursor$FETCH.v_value, v_cursor$FETCH.v_date;

    IF FOUND THEN
        v_id := v_cursor$FETCH.v_id;
        v_name := v_cursor$FETCH.v_name;
        v_value := v_cursor$FETCH.v_value;
        v_date := v_cursor$FETCH.v_date;
        v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
    ELSE
        v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
    END IF;

    IF v_cursor$ATTRIBUTES.found THEN
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_id));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '名前: ', v_name));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '値: ', v_value));
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '作成日: ', aws_oracle_ext.TO_CHAR(v_date, 'YYYY-MM-DD')));
    ELSE
        CALL aws_oracle_ext.dbms_output$put_line(a => 'データが見つかりませんでした。');
    END IF;
    /* カーソルを閉じる */
    CLOSE v_cursor;
    v_cursor$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    /* メイン処理のコミット */
    
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    EXCEPTION
        WHEN others THEN
            IF v_cursor$ATTRIBUTES.isopen THEN
                CLOSE v_cursor;
                v_cursor$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
            END IF;
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0069_process_with_cursor(IN p_id DOUBLE PRECISION, OUT p_cursor REFCURSOR)
AS 
$BODY$
DECLARE
    aws_params JSON := json_build_object('p_id', p_id, 'p_cursor', p_cursor);
    aws_session_env JSON;
BEGIN
    SELECT
        *
        FROM aws_oracle_ext.autonomous_exec('CALL schema_sample.sct_0069_process_with_cursor$at('||quote_nullable(aws_params)||','||quote_nullable(aws_session_env)||')')
        INTO aws_params, aws_session_env;
    SELECT
        t.p_cursor
        INTO p_cursor
        FROM json_to_record(aws_params)
            AS t (p_cursor REFCURSOR);
END
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0069_process_with_cursor$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
AS 
$BODY$
DECLARE
    p_id DOUBLE PRECISION;
    /* [5664 - Severity LOW - PostgreSQL doesn't support cursor variables defined with PRAGMA AUTONOMOUS_TRANSACTION as routine parameters. Review the converted code and change it where necessary.] */
    p_cursor REFCURSOR;
    p_cursor$ATTRIBUTES aws_oracle_data.TCursorAttributes;
BEGIN
/* ログを記録 */
    SELECT
        t.p_id, t.p_cursor
        INTO p_id, p_cursor
        FROM json_to_record(aws_params)
            AS t (p_id DOUBLE PRECISION, p_cursor REFCURSOR);
    INSERT INTO schema_sample.t_0069_log (log_id, operation, table_name, record_id)
    VALUES (nextval('schema_sample.t_0069_log_seq'), 'SELECT', 'T_0069', p_id);
    /* 自律トランザクションをコミット */
    COMMIT;
    /* カーソルを開く */
    p_cursor := NULL;
    OPEN p_cursor FOR
    SELECT
        id, name, value, created_date
        FROM schema_sample.t_0069
        WHERE id = p_id;
    p_cursor$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    sct_0069_process_with_cursor$at.aws_params := json_build_object('p_cursor', p_cursor);
END;
$BODY$
LANGUAGE plpgsql;
COMMENT ON PROCEDURE schema_sample.sct_0069_process_with_cursor$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
     IS 'Belongs to: schema_sample.sct_0069_process_with_cursor';

CREATE OR REPLACE PROCEDURE schema_sample.sct_0070_insert_with_context(IN p_id DOUBLE PRECISION, IN p_name TEXT, IN p_value DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    aws_params JSON := json_build_object('p_id', p_id, 'p_name', p_name, 'p_value', p_value);
    aws_session_env JSON;
BEGIN
    SELECT
        *
        FROM aws_oracle_ext.autonomous_exec('CALL schema_sample.sct_0070_insert_with_context$at('||quote_nullable(aws_params)||','||quote_nullable(aws_session_env)||')')
        INTO aws_params, aws_session_env;
END
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0070_insert_with_context$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
AS 
$BODY$
DECLARE
    v_user CHARACTER VARYING(30);
    p_id DOUBLE PRECISION;
    p_name TEXT;
    p_value DOUBLE PRECISION;
BEGIN
/* アプリケーションコンテキストから現在のユーザーIDを取得 */
    SELECT
        t.p_id, t.p_name, t.p_value
        INTO p_id, p_name, p_value
        FROM json_to_record(aws_params)
            AS t (p_id DOUBLE PRECISION, p_name TEXT, p_value DOUBLE PRECISION);
    v_user := aws_oracle_ext.SYS_CONTEXT('SCT_0070_user_ctx', 'user_id');
    /* ユーザーIDが設定されていない場合はデフォルト値を使用 */

    IF v_user IS NULL THEN
        v_user := 'UNKNOWN';
    END IF;
    /* テーブルにデータを挿入 */
    INSERT INTO schema_sample.t_0070 (id, name, value, created_by, created_date)
    VALUES (p_id, p_name, p_value, v_user, (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0));
    /* 自律型トランザクション内でコミット */
    
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'レコードが挿入されました。ID: ', p_id, ', 作成者: ', v_user));
    EXCEPTION
        WHEN others THEN
            /* エラー発生時はロールバック */
            
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;
COMMENT ON PROCEDURE schema_sample.sct_0070_insert_with_context$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
     IS 'Belongs to: schema_sample.sct_0070_insert_with_context';

CREATE OR REPLACE PROCEDURE schema_sample.sct_0070_update_with_context(IN p_id DOUBLE PRECISION, IN p_new_value DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    aws_params JSON := json_build_object('p_id', p_id, 'p_new_value', p_new_value);
    aws_session_env JSON;
BEGIN
    SELECT
        *
        FROM aws_oracle_ext.autonomous_exec('CALL schema_sample.sct_0070_update_with_context$at('||quote_nullable(aws_params)||','||quote_nullable(aws_session_env)||')')
        INTO aws_params, aws_session_env;
END
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0070_update_with_context$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
AS 
$BODY$
DECLARE
    v_user CHARACTER VARYING(30);
    v_log_message CHARACTER VARYING(200);
    p_id DOUBLE PRECISION;
    p_new_value DOUBLE PRECISION;
BEGIN
/* アプリケーションコンテキストから現在のユーザーIDを取得 */
    SELECT
        t.p_id, t.p_new_value
        INTO p_id, p_new_value
        FROM json_to_record(aws_params)
            AS t (p_id DOUBLE PRECISION, p_new_value DOUBLE PRECISION);
    v_user := aws_oracle_ext.SYS_CONTEXT('SCT_0070_user_ctx', 'user_id');
    /* ユーザーIDが設定されていない場合はデフォルト値を使用 */

    IF v_user IS NULL THEN
        v_user := 'UNKNOWN';
    END IF;
    /* ログメッセージを作成 */
    v_log_message := CONCAT_WS('', 'ユーザー ', v_user, ' がID=', p_id, ' のレコードを更新しました。新しい値: ', p_new_value);
    /* テーブルを更新 */
    UPDATE schema_sample.t_0070
    SET value = p_new_value
        WHERE id = p_id;
    /* 自律型トランザクション内でコミット */
    
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => v_log_message);
    EXCEPTION
        WHEN others THEN
            /* エラー発生時はロールバック */
            
            /*
            [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
            ROLLBACK
            */
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;
COMMENT ON PROCEDURE schema_sample.sct_0070_update_with_context$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
     IS 'Belongs to: schema_sample.sct_0070_update_with_context';

CREATE OR REPLACE PROCEDURE schema_sample.sct_0070_user_ctx_pkg$set_user_id(IN p_user_id TEXT)
AS 
$BODY$
BEGIN
    PERFORM aws_oracle_ext.DBMS_SESSION$SET_CONTEXT('SCT_0070_user_ctx', 'user_id', p_user_id);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0071_cursor_sync_issue_demo()
AS 
$BODY$
/* メインプロシージャのカーソル */
DECLARE
    /* 自律トランザクションを持つネストされたプロシージャ */
    main_cursor$825ade8a$ATTRIBUTES aws_oracle_data.THldCursorAttributes;
    main_cursor$825ade8a refcursor := 'schema_sample$sct_0071_cursor_sync_issue_demo$main_cursor'::refcursor;
    main_cursor$825ade8a$FETCH RECORD;
BEGIN
    PERFORM aws_oracle_ext.packageinitialize(proutinename => 'schema_sample.sct_0071_cursor_sync_issue_demo', pforce => TRUE);
    SELECT
        NULL::VARCHAR(8000) AS data
        INTO main_cursor$825ade8a$FETCH;
    CALL aws_oracle_ext.dbms_output$put_line(a => 'メインプロシージャ開始');
    /* メインカーソルを開く */
    PERFORM schema_sample.sct_0071_cursor_sync_issue_demo$main_cursor$31468eb8();
    main_cursor$825ade8a$ATTRIBUTES := ROW (0, NULL, NULL);
    /* メインカーソルをループ処理 */

    LOOP
        FETCH main_cursor$825ade8a INTO main_cursor$825ade8a$FETCH.data;

        IF FOUND THEN
            v_main_rec := main_cursor$825ade8a$FETCH;
            main_cursor$825ade8a$ATTRIBUTES := row(coalesce(main_cursor$825ade8a$ATTRIBUTES.rowcount, 0) + 1, FOUND, NOT FOUND);
        ELSE
            main_cursor$825ade8a$ATTRIBUTES := row(coalesce(main_cursor$825ade8a$ATTRIBUTES.rowcount, 0), FOUND, NOT FOUND);
        END IF;
        EXIT WHEN main_cursor$825ade8a$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'メイン処理: ', v_main_rec.data));
        /* 自律トランザクションプロシージャを呼び出す */
        CALL schema_sample.sct_0071_cursor_sync_issue_demo$autonomous_proc$d6bf4d0e(v_main_rec.data);
        /* カーソル状態の確認 */

        IF aws_oracle_ext.isopen('schema_sample$sct_0071_cursor_sync_issue_demo$main_cursor') THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => 'メイン処理: カーソルはまだ開いています');
        ELSE
            CALL aws_oracle_ext.dbms_output$put_line(a => 'メイン処理: カーソルが閉じられました！');
            /* カーソルが閉じられた場合は再度開く */
            PERFORM schema_sample.sct_0071_cursor_sync_issue_demo$main_cursor$31468eb8();
            main_cursor$825ade8a$ATTRIBUTES := ROW (0, NULL, NULL);
        END IF;
    END LOOP;
    /* メインカーソルを閉じる */
    CLOSE main_cursor$825ade8a;
    main_cursor$825ade8a$ATTRIBUTES := ROW (NULL, NULL, NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => 'メインプロシージャ終了');
    EXCEPTION
        WHEN others THEN
            IF aws_oracle_ext.isopen('schema_sample$sct_0071_cursor_sync_issue_demo$main_cursor') THEN
                CLOSE main_cursor$825ade8a;
                main_cursor$825ade8a$ATTRIBUTES := ROW (NULL, NULL, NULL);
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0071_cursor_sync_issue_demo$autonomous_proc$d6bf4d0e(IN p_value TEXT)
AS 
$BODY$
DECLARE
    aws_params JSON := json_build_object('p_value', p_value);
    aws_session_env JSON := aws_oracle_ext.session_env_store('schema_sample.sct_0071_cursor_sync_issue_demo.v_main_rec');
BEGIN
    SELECT
        *
        FROM aws_oracle_ext.autonomous_exec('CALL schema_sample.sct_0071_cursor_sync_issue_demo$autonomous_proc$d6bf4d0e$at('||quote_nullable(aws_params)||','||quote_nullable(aws_session_env)||')')
        INTO aws_params, aws_session_env;
END
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0071_cursor_sync_issue_demo$autonomous_proc$d6bf4d0e$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
AS 
$BODY$
/* schema_sample.sct_0071_cursor_sync_issue_demo.autonomous_proc */
DECLARE
    p_value TEXT;
    main_cursor$825ade8a$ATTRIBUTES aws_oracle_data.THldCursorAttributes;
    main_cursor$825ade8a refcursor := 'schema_sample$sct_0071_cursor_sync_issue_demo$main_cursor'::refcursor;
    main_cursor$825ade8a$FETCH RECORD;
/* 自律トランザクション内でメインカーソルを参照しようとする */
/* これが同期の問題を引き起こす */
BEGIN
/* 問題のあるコード: 自律トランザクション内から外部カーソルの状態に依存 */
    PERFORM aws_oracle_ext.session_env_restore(aws_session_env);
    SELECT
        t.p_value
        INTO p_value
        FROM json_to_record(aws_params)
            AS t (p_value TEXT);
    SELECT
        NULL::VARCHAR(8000) AS data
        INTO main_cursor$825ade8a$FETCH;

    IF aws_oracle_ext.isopen('schema_sample$sct_0071_cursor_sync_issue_demo$main_cursor') THEN
        /* 外部カーソルが開いている場合の処理 */
        CALL aws_oracle_ext.dbms_output$put_line(a => '自律トランザクション内: 外部カーソルは開いています');
        /* 問題のあるコード: 自律トランザクション内から外部カーソルを操作 */
        FETCH main_cursor$825ade8a INTO main_cursor$825ade8a$FETCH.data;

        IF FOUND THEN
            v_main_rec := main_cursor$825ade8a$FETCH;
            main_cursor$825ade8a$ATTRIBUTES := row(coalesce(main_cursor$825ade8a$ATTRIBUTES.rowcount, 0) + 1, FOUND, NOT FOUND);
        ELSE
            main_cursor$825ade8a$ATTRIBUTES := row(coalesce(main_cursor$825ade8a$ATTRIBUTES.rowcount, 0), FOUND, NOT FOUND);
        END IF;

        IF main_cursor$825ade8a$ATTRIBUTES.found THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '自律トランザクション内: 取得した値 = ', v_main_rec.data));
        ELSE
            CALL aws_oracle_ext.dbms_output$put_line(a => '自律トランザクション内: これ以上データがありません');
        END IF;
    ELSE
        CALL aws_oracle_ext.dbms_output$put_line(a => '自律トランザクション内: 外部カーソルは閉じています');
    END IF;
    /* 自律トランザクションをコミット */
    COMMIT;
END;
$BODY$
LANGUAGE plpgsql;
COMMENT ON PROCEDURE schema_sample.sct_0071_cursor_sync_issue_demo$autonomous_proc$d6bf4d0e$at(INOUT aws_params JSON, INOUT aws_session_env JSON)
     IS 'Belongs to: schema_sample.sct_0071_cursor_sync_issue_demo$autonomous_proc$d6bf4d0e';

CREATE OR REPLACE PROCEDURE schema_sample.sct_0072_case_test(IN p_id DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_name CHARACTER VARYING(100);
BEGIN
    SELECT
        name
        INTO STRICT v_name
        FROM schema_sample.t_0072
        WHERE id = p_id;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '大文字バージョン: ', v_name));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0072_get_item(IN p_min_value DOUBLE PRECISION, IN p_max_value DOUBLE PRECISION, OUT p_count DOUBLE PRECISION)
AS 
$BODY$
BEGIN
    SELECT
        COUNT(*)
        INTO STRICT p_count
        FROM schema_sample.t_0072
        WHERE value BETWEEN p_min_value AND p_max_value;
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', '値の範囲でアイテム数を取得: ', p_min_value, ' - ', p_max_value));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0072_pkg$process_item(IN p_id DOUBLE PRECISION)
AS 
$BODY$
BEGIN
    UPDATE schema_sample.t_0072
    SET value = value + 10
        WHERE id = p_id;
    COMMIT;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0072_pkg$process_item(IN p_name TEXT)
AS 
$BODY$
BEGIN
    UPDATE schema_sample.t_0072
    SET value = value + 20
        WHERE name = p_name;
    COMMIT;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0073_create_complex_index(IN p_table_name TEXT, IN p_index_name TEXT)
AS 
$BODY$
DECLARE
    v_sql CHARACTER VARYING(4000);
    v_exists DOUBLE PRECISION;
BEGIN
/* テーブルが存在するか確認 */
    SELECT
        COUNT(*)
        INTO STRICT v_exists
        WHERE EXISTS (SELECT
            1
            FROM aws_oracle_ext.SYS_USER_TABLES
            WHERE table_name = UPPER(p_table_name));

    IF v_exists = 0 THEN
        /* テスト用のテーブルを作成 */
        EXECUTE CONCAT_WS('', 'CREATE TABLE ', p_table_name, ' (', 'id NUMBER, ', 'name VARCHAR2(100), ', 'description VARCHAR2(4000))');
    END IF;
    /* Oracle固有のインデックスタイプを作成 */
    v_sql := CONCAT_WS('', 'CREATE BITMAP INDEX ', p_index_name, ' ON ', p_table_name, '(name) ', 'TABLESPACE users ', 'NOLOGGING ', 'COMPRESS 2 ', 'PARALLEL 4');
    EXECUTE v_sql;
    /* 確認メッセージ */
    SELECT
        CONCAT_WS('', 'インデックス ', p_index_name, ' が作成されました')
        INTO STRICT v_sql;
    CALL aws_oracle_ext.dbms_output$put_line(a => v_sql);
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0073_create_dynamic_table(IN p_table_name TEXT, IN p_column_name TEXT)
AS 
$BODY$
DECLARE
    v_sql CHARACTER VARYING(4000);
BEGIN
/* 動的にテーブルを作成するDDL */
    v_sql := CONCAT_WS('', 'CREATE T ', p_table_name, ' ABLE IF NOT EXISTS sct_0073_create_dynamic_table.aws_stub (', p_column_name, ' ');
    /* 動的DDLを実行 */
    EXECUTE v_sql;
    /* 確認メッセージ */
    SELECT
        CONCAT_WS('', 'テーブル ', p_table_name, ' が作成されました')
        INTO STRICT v_sql;
    CALL aws_oracle_ext.dbms_output$put_line(a => v_sql);
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0073_create_materialized_view(IN p_mview_name TEXT)
AS 
$BODY$
DECLARE
    v_sql CHARACTER VARYING(4000);
    v_dummy CHARACTER VARYING(100);
BEGIN
/* Oracle固有のマテリアライズドビュー作成 */
    v_sql := CONCAT_WS('', 'CREATE MATERIALIZED VIEW ', p_mview_name, ' ', 'BUILD IMMEDIATE ', 'REFRESH FAST ON COMMIT ', 'ENABLE QUERY REWRITE ', 'AS ', 'SELECT ''X'' AS dummy FROM DUAL');
    /*
    [5966 - Severity CRITICAL - DMS SC can't convert the CREATE MATERIALIZED VIEW DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
    EXECUTE IMMEDIATE v_sql
    */
    /* マテリアライズドビューログの作成 */
    v_sql := CONCAT_WS('', 'CREATE MATERIALIZED VIEW LOG ON DUAL ', 'WITH ROWID, SEQUENCE, PRIMARY KEY ', 'INCLUDING NEW VALUES');
    /*
    [5966 - Severity CRITICAL - DMS SC can't convert the CREATE MATERIALIZED VIEW LOG DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
    EXECUTE IMMEDIATE v_sql
    */
    /* 確認メッセージ */
    SELECT
        CONCAT_WS('', 'マテリアライズドビュー ', p_mview_name, ' が作成されました')
        INTO STRICT v_dummy;
    CALL aws_oracle_ext.dbms_output$put_line(a => v_dummy);
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0073_create_partitioned_table(IN p_table_name TEXT)
AS 
$BODY$
DECLARE
    v_sql CHARACTER VARYING(4000);
    v_dummy CHARACTER VARYING(100);
BEGIN
/* Oracle固有のパーティショニングを使用したテーブル作成 */
    v_sql := CONCAT_WS('', 'CREATE TABLE ', p_table_name, ' (', 'id NUMBER, ', 'trans_date DATE, ', 'amount NUMBER(10,2), ', 'description VARCHAR2(200)', ') ', 'PARTITION BY RANGE (trans_date) ', 'INTERVAL(NUMTOYMINTERVAL(1, ''MONTH'')) ', 'STORE IN (users) ', '(', 'PARTITION p_start VALUES LESS THAN (TO_DATE(''2023-01-01'', ''YYYY-MM-DD''))', ')');
    EXECUTE v_sql;
    /* 確認メッセージ */
    SELECT
        CONCAT_WS('', 'パーティションテーブル ', p_table_name, ' が作成されました')
        INTO STRICT v_dummy;
    CALL aws_oracle_ext.dbms_output$put_line(a => v_dummy);
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0073_create_table_with_oracle_features(IN p_table_name TEXT)
AS 
$BODY$
DECLARE
    v_sql CHARACTER VARYING(4000);
    v_count DOUBLE PRECISION;
BEGIN
/* テーブルが存在するか確認 */
    SELECT
        COUNT(*)
        INTO STRICT v_count
        WHERE EXISTS (SELECT
            1
            FROM aws_oracle_ext.SYS_USER_TABLES
            WHERE table_name = UPPER(p_table_name));

    IF v_count > 0 THEN
        /* テーブルが存在する場合は削除 */
        EXECUTE CONCAT_WS('', 'DROP TABLE  ', p_table_name, ' ;');
    END IF;
    /* Oracle固有の機能を使用したテーブル作成 */
    v_sql := CONCAT_WS('', 'CREATE TABLE ', p_table_name, ' (', 'id NUMBER GENERATED ALWAYS AS IDENTITY, ', 'name VARCHAR2(100), ', 'created_date DATE DEFAULT SYSDATE, ', 'data BLOB, ', 'CONSTRAINT ', p_table_name, '_pk PRIMARY KEY (id) ', ') ', 'ORGANIZATION INDEX ', 'TABLESPACE users ', 'STORAGE (INITIAL 1M NEXT 1M) ', 'LOGGING ', 'MONITORING');
    EXECUTE v_sql;
    /* 確認メッセージ */
    SELECT
        CONCAT_WS('', 'テーブル ', p_table_name, ' が作成されました')
        INTO STRICT v_sql;
    CALL aws_oracle_ext.dbms_output$put_line(a => v_sql);
    EXCEPTION
        WHEN others THEN
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0074_collate_sort()
AS 
$BODY$
/* カーソルの宣言（静的SQL） */
DECLARE
    c_japanese_sort CURSOR FOR
    SELECT
        id, name, kana
        FROM schema_sample.t_0074
        ORDER BY kana COLLATE japanese ASC;
    c_japanese_sort$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    c_default_sort CURSOR FOR
    SELECT
        id, name, kana
        FROM schema_sample.t_0074
        ORDER BY kana ASC;
    c_default_sort$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    /* レコード変数の宣言 */
    v_record schema_sample.sct_0074_collate_sort$c_japanese_sort := ROW (NULL, NULL, NULL)::schema_sample.sct_0074_collate_sort$c_japanese_sort;
    c_japanese_sort$FETCH RECORD;
    c_default_sort$FETCH RECORD;
BEGIN
    SELECT
        NULL::DOUBLE PRECISION AS id, NULL::CHARACTER VARYING(100) AS name, NULL::CHARACTER VARYING(100) AS kana
        INTO c_japanese_sort$FETCH;
    SELECT
        NULL::DOUBLE PRECISION AS id, NULL::CHARACTER VARYING(100) AS name, NULL::CHARACTER VARYING(100) AS kana
        INTO c_default_sort$FETCH;
    CALL aws_oracle_ext.dbms_output$put_line(a => '日本語照合順序（COLLATE JAPANESE）を使用した結果:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------------------');
    /* 日本語照合順序でソートしたデータを取得 */
    c_japanese_sort := NULL;
    OPEN c_japanese_sort;
    c_japanese_sort$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);

    LOOP
        FETCH c_japanese_sort INTO c_japanese_sort$FETCH.id, c_japanese_sort$FETCH.name, c_japanese_sort$FETCH.kana;

        IF FOUND THEN
            v_record := c_japanese_sort$FETCH;
            c_japanese_sort$ATTRIBUTES := row(c_japanese_sort$ATTRIBUTES.isopen, c_japanese_sort$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            c_japanese_sort$ATTRIBUTES := row(c_japanese_sort$ATTRIBUTES.isopen, c_japanese_sort$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN c_japanese_sort$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_record.id, ', 名前: ', v_record.name, ', カナ: ', v_record.kana));
    END LOOP;
    CLOSE c_japanese_sort;
    c_japanese_sort := NULL;
    c_japanese_sort$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    /* 比較のため、デフォルトの照合順序を使用 */
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => 'デフォルト照合順序を使用した結果:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '-------------------------------');
    /* デフォルト照合順序でソートしたデータを取得 */
    c_default_sort := NULL;
    OPEN c_default_sort;
    c_default_sort$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);

    LOOP
        FETCH c_default_sort INTO c_default_sort$FETCH.id, c_default_sort$FETCH.name, c_default_sort$FETCH.kana;

        IF FOUND THEN
            v_record := c_default_sort$FETCH;
            c_default_sort$ATTRIBUTES := row(c_default_sort$ATTRIBUTES.isopen, c_default_sort$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            c_default_sort$ATTRIBUTES := row(c_default_sort$ATTRIBUTES.isopen, c_default_sort$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN c_default_sort$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_record.id, ', 名前: ', v_record.name, ', カナ: ', v_record.kana));
    END LOOP;
    CLOSE c_default_sort;
    c_default_sort := NULL;
    c_default_sort$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    EXCEPTION
        WHEN others THEN
            /* エラー処理 */
            IF c_japanese_sort$ATTRIBUTES.isopen THEN
                CLOSE c_japanese_sort;
            END IF;

            IF c_default_sort$ATTRIBUTES.isopen THEN
                CLOSE c_default_sort;
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0074_japanese_sort(IN p_sort_field TEXT DEFAULT 'KANA', IN p_sort_order TEXT DEFAULT 'ASC')
AS 
$BODY$
/* カーソル変数の宣言 */
DECLARE
    v_cursor REFCURSOR;
    v_cursor$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    /* レコード変数の宣言 */
    v_id schema_sample.t_0074.id%TYPE;
    v_name schema_sample.t_0074.name%TYPE;
    v_kana schema_sample.t_0074.kana%TYPE;
    /* 動的SQL用の変数 */
    v_sql CHARACTER VARYING(1000);
    v_cursor$FETCH RECORD;
BEGIN
/* セッションの言語ソートを日本語に設定 */
    SELECT
        NULL::DOUBLE PRECISION AS v_id, NULL::CHARACTER VARYING(100) AS v_name, NULL::CHARACTER VARYING(100) AS v_kana
        INTO v_cursor$FETCH;
    /*
    [5966 - Severity CRITICAL - DMS SC can't convert the ALTER SESSION DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = JAPANESE'
    */
    /*
    [5966 - Severity CRITICAL - DMS SC can't convert the ALTER SESSION DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_COMP = LINGUISTIC'
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => '日本語ソートを使用した結果:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '-------------------------------');
    /* 動的SQLの構築 */
    v_sql := CONCAT_WS('', 'SELECT ID, NAME, KANA FROM T_0074 ORDER BY ', p_sort_field, ' ', p_sort_order);
    /* カーソルを開く */
    v_cursor := NULL;
    OPEN v_cursor FOR
    EXECUTE v_sql;
    v_cursor$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    /* 結果を取得して表示 */

    LOOP
        FETCH v_cursor INTO v_cursor$FETCH.v_id, v_cursor$FETCH.v_name, v_cursor$FETCH.v_kana;

        IF FOUND THEN
            v_id := v_cursor$FETCH.v_id;
            v_name := v_cursor$FETCH.v_name;
            v_kana := v_cursor$FETCH.v_kana;
            v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN v_cursor$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_id, ', 名前: ', v_name, ', カナ: ', v_kana));
    END LOOP;
    /* カーソルを閉じる */
    CLOSE v_cursor;
    v_cursor$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    /* 比較のため、バイナリソートに戻す */
    
    /*
    [5966 - Severity CRITICAL - DMS SC can't convert the ALTER SESSION DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = BINARY'
    */
    
    /*
    [5966 - Severity CRITICAL - DMS SC can't convert the ALTER SESSION DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_COMP = BINARY'
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => 'バイナリソートを使用した結果:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '-------------------------------');
    /* 同じクエリを実行（今度はバイナリソート） */
    v_cursor := NULL;
    OPEN v_cursor FOR
    EXECUTE v_sql;
    v_cursor$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);
    /* 結果を取得して表示 */

    LOOP
        FETCH v_cursor INTO v_cursor$FETCH.v_id, v_cursor$FETCH.v_name, v_cursor$FETCH.v_kana;

        IF FOUND THEN
            v_id := v_cursor$FETCH.v_id;
            v_name := v_cursor$FETCH.v_name;
            v_kana := v_cursor$FETCH.v_kana;
            v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            v_cursor$ATTRIBUTES := row(v_cursor$ATTRIBUTES.isopen, v_cursor$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN v_cursor$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_id, ', 名前: ', v_name, ', カナ: ', v_kana));
    END LOOP;
    /* カーソルを閉じる */
    CLOSE v_cursor;
    v_cursor$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    EXCEPTION
        WHEN others THEN
            /* エラー処理 */
            IF v_cursor$ATTRIBUTES.isopen THEN
                CLOSE v_cursor;
                v_cursor$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            /* セッション設定を元に戻す */
            
            /*
            [5966 - Severity CRITICAL - DMS SC can't convert the ALTER SESSION DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
            EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_SORT = BINARY'
            */
            
            /*
            [5966 - Severity CRITICAL - DMS SC can't convert the ALTER SESSION DDL statement. Revise your code to avoid using this statement and try again. Or convert your source code manually.]
            EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_COMP = BINARY'
            */
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0074_nlssort_japanese()
AS 
$BODY$
/* カーソルの宣言（静的SQL） */
DECLARE
    c_japanese_sort CURSOR FOR
    SELECT
        id, name, kana
        FROM schema_sample.t_0074
        ORDER BY KANA;
    c_japanese_sort$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    c_default_sort CURSOR FOR
    SELECT
        id, name, kana
        FROM schema_sample.t_0074
        ORDER BY kana;
    c_default_sort$ATTRIBUTES aws_oracle_data.TCursorAttributes := ROW (FALSE, NULL, NULL, NULL);
    /* レコード変数の宣言 */
    v_record schema_sample.sct_0074_nlssort_japanese$c_japanese_sort := ROW (NULL, NULL, NULL)::schema_sample.sct_0074_nlssort_japanese$c_japanese_sort;
    c_japanese_sort$FETCH RECORD;
    c_default_sort$FETCH RECORD;
BEGIN
    SELECT
        NULL::DOUBLE PRECISION AS id, NULL::CHARACTER VARYING(100) AS name, NULL::CHARACTER VARYING(100) AS kana
        INTO c_japanese_sort$FETCH;
    SELECT
        NULL::DOUBLE PRECISION AS id, NULL::CHARACTER VARYING(100) AS name, NULL::CHARACTER VARYING(100) AS kana
        INTO c_default_sort$FETCH;
    CALL aws_oracle_ext.dbms_output$put_line(a => '日本語ソート（NLSSORT）を使用した結果:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '----------------------------------');
    /* 日本語ソートでデータを取得 */
    c_japanese_sort := NULL;
    OPEN c_japanese_sort;
    c_japanese_sort$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);

    LOOP
        FETCH c_japanese_sort INTO c_japanese_sort$FETCH.id, c_japanese_sort$FETCH.name, c_japanese_sort$FETCH.kana;

        IF FOUND THEN
            v_record := c_japanese_sort$FETCH;
            c_japanese_sort$ATTRIBUTES := row(c_japanese_sort$ATTRIBUTES.isopen, c_japanese_sort$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            c_japanese_sort$ATTRIBUTES := row(c_japanese_sort$ATTRIBUTES.isopen, c_japanese_sort$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN c_japanese_sort$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_record.id, ', 名前: ', v_record.name, ', カナ: ', v_record.kana));
    END LOOP;
    CLOSE c_japanese_sort;
    c_japanese_sort := NULL;
    c_japanese_sort$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    /* 比較のため、デフォルトのソートを使用 */
    CALL aws_oracle_ext.dbms_output$put_line(a => NULL);
    CALL aws_oracle_ext.dbms_output$put_line(a => 'デフォルトソートを使用した結果:');
    CALL aws_oracle_ext.dbms_output$put_line(a => '---------------------------');
    /* デフォルトソートでデータを取得 */
    c_default_sort := NULL;
    OPEN c_default_sort;
    c_default_sort$ATTRIBUTES := ROW (TRUE, 0, NULL, NULL);

    LOOP
        FETCH c_default_sort INTO c_default_sort$FETCH.id, c_default_sort$FETCH.name, c_default_sort$FETCH.kana;

        IF FOUND THEN
            v_record := c_default_sort$FETCH;
            c_default_sort$ATTRIBUTES := row(c_default_sort$ATTRIBUTES.isopen, c_default_sort$ATTRIBUTES.rowcount + 1, FOUND, NOT FOUND);
        ELSE
            c_default_sort$ATTRIBUTES := row(c_default_sort$ATTRIBUTES.isopen, c_default_sort$ATTRIBUTES.rowcount, FOUND, NOT FOUND);
        END IF;
        EXIT WHEN c_default_sort$ATTRIBUTES.notfound;
        CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID: ', v_record.id, ', 名前: ', v_record.name, ', カナ: ', v_record.kana));
    END LOOP;
    CLOSE c_default_sort;
    c_default_sort := NULL;
    c_default_sort$ATTRIBUTES := ROW (FALSE, NULL, NULL, NULL);
    EXCEPTION
        WHEN others THEN
            /* エラー処理 */
            IF c_japanese_sort$ATTRIBUTES.isopen THEN
                CLOSE c_japanese_sort;
            END IF;

            IF c_default_sort$ATTRIBUTES.isopen THEN
                CLOSE c_default_sort;
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0075_forall(IN min_sleep NUMERIC, IN max_sleep NUMERIC)
AS 
$BODY$
DECLARE
    prodList schema_sample.sct_0075_forall$prodlisttype := ARRAY[]::schema_sample.sct_0075_forall$prodlisttype;
    warehouseList schema_sample.sct_0075_forall$warehouselisttype := ARRAY[]::schema_sample.sct_0075_forall$warehouselisttype;
    noOrderedList schema_sample.sct_0075_forall$noorderedlisttype := ARRAY[]::schema_sample.sct_0075_forall$noorderedlisttype;
    AWAITING_PROCESSING NUMERIC(38) := 4;
BEGIN
    /* [9996 - Severity CRITICAL - Transformer error occurred in updateStatement. Please submit report to developers.] */
    BEGIN
    END;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0076_read_file(IN p_directory_name TEXT, IN p_file_name TEXT)
AS 
$BODY$
DECLARE
    v_file aws_oracle_ext.UTL_FILE$FILE_TYPE;
    v_line CHARACTER VARYING(32767);
    v_content TEXT := NULL;
    v_file_id DOUBLE PRECISION;
BEGIN
/* ディレクトリが存在するか確認 */
    IF NOT aws_oracle_ext.UTL_FILE$IS_OPEN(v_file) THEN
        /* ファイルを開く */
        v_file := aws_oracle_ext.UTL_FILE$FOPEN(p_directory_name, p_file_name, 'R');
    END IF;
    /* 新しいIDを生成 */
    SELECT
        COALESCE(MAX(id), 0) + 1
        INTO STRICT v_file_id
        FROM schema_sample.t_0076;
    /* ファイルの内容を読み込む */

    BEGIN
        LOOP
            PERFORM aws_oracle_ext.UTL_FILE$GET_LINE(v_file, v_line);
            v_content := (CONCAT_WS('', v_content, v_line, CHR(10)))::TEXT;
        END LOOP;
        /* ファイルの終わりに達した */
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
    END;
    /* ファイルを閉じる */
    PERFORM aws_oracle_ext.UTL_FILE$FCLOSE(v_file);
    /* テーブルにデータを挿入 */
    INSERT INTO schema_sample.t_0076 (id, filename, content, created_date, updated_date)
    VALUES (v_file_id, p_file_name, v_content, (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0), (CLOCK_TIMESTAMP() AT TIME ZONE COALESCE(CURRENT_SETTING('aws_oracle_ext.tz', TRUE), 'UTC'))::TIMESTAMP(0));
    /*
    [5035 - Severity CRITICAL - Your code ends a transaction inside a block with exception handlers. Revise your code to move transaction control to the application side and try again.]
    COMMIT
    */
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ファイル ', p_file_name, ' を読み込み、テーブルに保存しました。'));
    EXCEPTION
        WHEN others THEN
            IF aws_oracle_ext.UTL_FILE$IS_OPEN(v_file) THEN
                PERFORM aws_oracle_ext.UTL_FILE$FCLOSE(v_file);
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE schema_sample.sct_0076_write_file(IN p_directory_name TEXT, IN p_file_name TEXT, IN p_id DOUBLE PRECISION)
AS 
$BODY$
DECLARE
    v_file aws_oracle_ext.UTL_FILE$FILE_TYPE;
    v_content TEXT;
    v_buffer CHARACTER VARYING(32767);
    v_position NUMERIC(38) := 1;
    v_chunk_size NUMERIC(38) := 32767;
    v_content_length NUMERIC(38);
BEGIN
/* テーブルからデータを取得 */
    SELECT
        content
        INTO STRICT v_content
        FROM schema_sample.t_0076
        WHERE id = p_id;
    v_content_length := aws_oracle_ext.dbms_lob$getlength(lob_loc => v_content);
    /* ファイルを書き込みモードで開く */
    v_file := aws_oracle_ext.UTL_FILE$FOPEN(p_directory_name, p_file_name, 'W');
    /* CLOBの内容をファイルに書き込む */

    WHILE v_position <= v_content_length LOOP
        v_buffer := aws_oracle_ext.dbms_lob$substr(lob_loc => v_content, amount => aws_oracle_ext.least(v_chunk_size::NUMERIC, (v_content_length - v_position + 1)::NUMERIC), "offset" => v_position);
        PERFORM aws_oracle_ext.UTL_FILE$PUT_LINE(v_file, v_buffer);
        v_position := v_position + v_chunk_size;
    END LOOP;
    /* ファイルを閉じる */
    PERFORM aws_oracle_ext.UTL_FILE$FCLOSE(v_file);
    CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'ID ', p_id, ' のデータをファイル ', p_file_name, ' に書き込みました。'));
    EXCEPTION
        WHEN others THEN
            IF aws_oracle_ext.UTL_FILE$IS_OPEN(v_file) THEN
                PERFORM aws_oracle_ext.UTL_FILE$FCLOSE(v_file);
            END IF;
            CALL aws_oracle_ext.dbms_output$put_line(a => CONCAT_WS('', 'エラーが発生しました: ', SQLERRM));
            RAISE;
END;
$BODY$
LANGUAGE plpgsql;

-- ------------ Write CREATE-TRIGGER-stage scripts -----------

CREATE TRIGGER t_0031_trigger
BEFORE UPDATE
ON schema_sample.t_0031
FOR EACH ROW
EXECUTE PROCEDURE schema_sample.t_0031_trigger$t_0031();

CREATE TRIGGER t_0032_usert_0032_trigger
AFTER INSERT OR UPDATE OR DELETE
ON schema_sample.t_0032
FOR EACH ROW
EXECUTE PROCEDURE schema_sample.t_0032_usert_0032_trigger$t_0032();

CREATE TRIGGER sct_0035_trigger
AFTER INSERT OR UPDATE OR DELETE
ON schema_sample.t_0035
FOR EACH ROW
EXECUTE PROCEDURE schema_sample.sct_0035_trigger$t_0035();

CREATE TRIGGER trigger_vc$t_0040
BEFORE INSERT OR UPDATE
ON schema_sample.t_0040
FOR EACH ROW
EXECUTE PROCEDURE schema_sample.f_trigger_vc$t_0040();

CREATE TRIGGER sct_0041_column_update_trigger
AFTER UPDATE
ON schema_sample.t_0041
FOR EACH ROW
EXECUTE PROCEDURE schema_sample.sct_0041_column_update_trigger$t_0041();

