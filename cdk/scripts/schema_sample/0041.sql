-- テーブルの作成
CREATE TABLE T_0041 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    STATUS VARCHAR2(20),
    VALUE NUMBER,
    LAST_UPDATED DATE
);

-- 監査ログテーブルの作成
-- 監査ログテーブルの作成
CREATE TABLE T_0041_AUDIT (
    AUDIT_ID NUMBER PRIMARY KEY,
    TABLE_NAME VARCHAR2(30),
    OPERATION VARCHAR2(10),
    COLUMN_NAME VARCHAR2(30),
    RECORD_ID NUMBER,
    OLD_VALUE VARCHAR2(4000),
    NEW_VALUE VARCHAR2(4000),
    CHANGED_BY VARCHAR2(30),
    CHANGE_DATE DATE
);

-- シーケンスの作成
CREATE SEQUENCE T_0041_AUDIT_SEQ START WITH 1 INCREMENT BY 1;

-- 条件述語 UPDATING('列名') を使用したトリガー
CREATE OR REPLACE TRIGGER SCT_0041_COLUMN_UPDATE_TRIGGER
AFTER UPDATE ON T_0041
FOR EACH ROW
BEGIN
    -- ID列が更新された場合
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
    END IF;

    -- NAME列が更新された場合
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
    END IF;

    -- STATUS列が更新された場合
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
    END IF;

    -- VALUE列が更新された場合
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
    END IF;
END SCT_0041_COLUMN_UPDATE_TRIGGER;
/
