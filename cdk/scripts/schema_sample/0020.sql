-- テーブルの作成
CREATE TABLE T_0020_DATA (
    ID NUMBER PRIMARY KEY,
    VALUE NUMBER,
    DESCRIPTION VARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE SCT_0020_SIMPLE_FORALL
IS
    -- データを格納するコレクション型
    TYPE t_id_tab IS TABLE OF T_0020_DATA.ID%TYPE;
    TYPE t_value_tab IS TABLE OF T_0020_DATA.VALUE%TYPE;

    -- コレクション変数
    v_ids t_id_tab;
    v_values t_value_tab;
    v_new_values t_value_tab;
BEGIN
    -- データの取得
    SELECT ID, VALUE
    BULK COLLECT INTO v_ids, v_values
    FROM T_0020_DATA;

    -- 新しい値の計算
    v_new_values := t_value_tab();
    v_new_values.EXTEND(v_ids.COUNT);

    FOR i IN 1..v_ids.COUNT LOOP
        v_new_values(i) := v_values(i) * 2;
    END LOOP;

    -- FORALLを使用した一括更新
    FORALL i IN 1..v_ids.COUNT
        UPDATE T_0020_DATA
        SET VALUE = v_new_values(i)
        WHERE ID = v_ids(i);

    -- 更新後に個別に値を表示
    FOR i IN 1..v_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_ids(i) || ', 旧値: ' || v_values(i) || ', 新値: ' || v_new_values(i));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('処理が完了しました。更新件数: ' || SQL%ROWCOUNT);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0020_SIMPLE_FORALL;
/
