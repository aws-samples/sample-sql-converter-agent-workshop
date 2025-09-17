-- オブジェクト型の作成
CREATE OR REPLACE TYPE T_0024_PERSON_TYPE AS OBJECT (
    person_id NUMBER,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    birth_date DATE,
    phone_number VARCHAR2(20),
    email VARCHAR2(100),

    -- メソッド宣言
    MEMBER FUNCTION get_full_name RETURN VARCHAR2,
    MEMBER FUNCTION get_age RETURN NUMBER,
    MEMBER PROCEDURE display_info
);
/

-- オブジェクト型の本体（メソッド実装）
CREATE OR REPLACE TYPE BODY T_0024_PERSON_TYPE AS
    -- フルネームを取得するメソッド
    MEMBER FUNCTION get_full_name RETURN VARCHAR2 IS
    BEGIN
        RETURN first_name || ' ' || last_name;
    END;

    -- 年齢を計算するメソッド
    MEMBER FUNCTION get_age RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_date) / 12);
    END;

    -- 情報を表示するメソッド
    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ID: ' || person_id);
        DBMS_OUTPUT.PUT_LINE('名前: ' || first_name || ' ' || last_name);
        DBMS_OUTPUT.PUT_LINE('生年月日: ' || TO_CHAR(birth_date, 'YYYY-MM-DD'));
        DBMS_OUTPUT.PUT_LINE('年齢: ' || FLOOR(MONTHS_BETWEEN(SYSDATE, birth_date) / 12));
        DBMS_OUTPUT.PUT_LINE('電話番号: ' || phone_number);
        DBMS_OUTPUT.PUT_LINE('メール: ' || email);
    END;
END;
/

-- オブジェクト表の作成
CREATE TABLE T_0024 OF T_0024_PERSON_TYPE (
    person_id PRIMARY KEY,
    email UNIQUE
);
