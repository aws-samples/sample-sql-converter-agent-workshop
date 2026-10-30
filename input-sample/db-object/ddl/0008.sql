-- テーブルの作成
CREATE TABLE T_0008 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    JSON_DATA CLOB CHECK (JSON_DATA IS JSON)
);

-- JSON_ARRAY_T型を使用したシンプルなプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0008_JSON_ARRAY_DEMO(
    p_id IN NUMBER,
    p_name IN VARCHAR2
)
IS
    -- JSON配列オブジェクトを宣言
    v_json_array JSON_ARRAY_T;
    v_json_object JSON_OBJECT_T;
    v_nested_array JSON_ARRAY_T;
    v_result CLOB;

    -- Oracle固有の型を使用
    v_anydata SYS.ANYDATA;
    v_xmltype XMLTYPE;
    v_interval INTERVAL DAY TO SECOND;

    -- フィールド値の割り当てを複雑にする変数
    TYPE t_rec IS RECORD (
        id NUMBER,
        name VARCHAR2(100),
        json_data JSON_ARRAY_T
    );
    v_record t_rec;
BEGIN
    -- 新しいJSON配列を作成
    v_json_array := JSON_ARRAY_T();

    -- 配列に要素を追加
    v_json_array.append('値1');
    v_json_array.append(123);

    -- JSONオブジェクトを作成
    v_json_object := JSON_OBJECT_T();
    v_json_object.put('name', p_name);
    v_json_object.put('id', p_id);
    v_json_array.append(v_json_object);

    -- 入れ子配列を作成
    v_nested_array := JSON_ARRAY_T();
    v_nested_array.append('入れ子配列');
    v_nested_array.append(456);
    v_nested_array.append(true);
    v_json_array.append(v_nested_array);

    -- Oracle固有の型を使用
    v_xmltype := XMLTYPE('<root><element>value</element></root>');
    v_interval := INTERVAL '2' DAY;
    v_anydata := SYS.ANYDATA.ConvertVarchar2('テストデータ');

    -- レコード型に値を割り当て
    v_record.id := p_id;
    v_record.name := p_name;
    v_record.json_data := v_json_array;

    -- 複雑なフィールド割り当て
    v_result := CASE
                  WHEN v_json_array.get_size() > 0 THEN
                    v_json_array.get_String(0) || ' - ' || v_xmltype.getClobVal()
                  ELSE
                    'empty'
                END;

    -- Oracle固有の関数を使用
    v_result := v_result || ' - ' ||
                TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.FF TZR') || ' - ' ||
                SYS_CONTEXT('USERENV', 'SESSION_USER');

    -- JSON配列を文字列に変換
    v_result := v_result || ' - ' || v_json_array.to_Clob();
    DBMS_OUTPUT.PUT_LINE('JSON配列の内容: ' || v_result);

    -- テーブルに保存（複雑な変換を含む）
    INSERT INTO T_0008 (ID, NAME, JSON_DATA)
    VALUES (
        v_record.id,
        SUBSTR(v_record.name || ' - ' || SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 100),
        v_result
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('JSONデータがテーブルに保存されました。');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        ROLLBACK;
END SCT_0008_JSON_ARRAY_DEMO;
/
