-- テーブルの作成
CREATE TABLE T_0042 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- CURSOR_ALREADY_OPEN例外を使用したシンプルなプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0042_DEMO_CURSOR_ALREADY_OPEN
IS
    -- 明示的カーソルの宣言
    CURSOR c_items IS
        SELECT ID, NAME, VALUE
        FROM T_0042
        ORDER BY ID;

    -- レコード変数の宣言
    v_item_rec c_items%ROWTYPE;
BEGIN
    -- カーソルを開く
    OPEN c_items;

    -- 最初のレコードを取得
    FETCH c_items INTO v_item_rec;
    DBMS_OUTPUT.PUT_LINE('最初のレコード: ID=' || v_item_rec.ID || ', NAME=' || v_item_rec.NAME);

    -- 意図的に同じカーソルを再度開こうとする（CURSOR_ALREADY_OPEN例外が発生）
    BEGIN
        OPEN c_items;  -- このカーソルは既に開いているため例外が発生
        DBMS_OUTPUT.PUT_LINE('この行は実行されません');
    EXCEPTION
        WHEN CURSOR_ALREADY_OPEN THEN
            DBMS_OUTPUT.PUT_LINE('CURSOR_ALREADY_OPEN例外が発生しました: カーソルは既に開いています');
    END;

    -- 残りのレコードを処理
    DBMS_OUTPUT.PUT_LINE('残りのレコードを処理します:');
    LOOP
        FETCH c_items INTO v_item_rec;
        EXIT WHEN c_items%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('レコード: ID=' || v_item_rec.ID || ', NAME=' || v_item_rec.NAME);
    END LOOP;

    -- カーソルを閉じる
    CLOSE c_items;

    -- 閉じたカーソルを再度開く（これは正常に動作する）
    BEGIN
        OPEN c_items;
        DBMS_OUTPUT.PUT_LINE('カーソルを再度開きました');
        CLOSE c_items;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('予期しないエラーが発生しました: ' || SQLERRM);
    END;

EXCEPTION
    WHEN OTHERS THEN
        -- メインブロックでの例外処理
        IF c_items%ISOPEN THEN
            CLOSE c_items;
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RAISE;
END SCT_0042_DEMO_CURSOR_ALREADY_OPEN;
/
