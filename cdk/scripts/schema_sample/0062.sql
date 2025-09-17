-- 結果として返すオブジェクト型を定義
CREATE OR REPLACE TYPE SCT_0062_data_obj_type AS OBJECT (
    id NUMBER,
    value VARCHAR2(100),
    calc_date DATE
);
/

-- オブジェクト型の表型を定義
CREATE OR REPLACE TYPE SCT_0062_data_tab_type AS TABLE OF SCT_0062_data_obj_type;
/

-- パイプライン化されたテーブル関数の作成
CREATE OR REPLACE FUNCTION SCT_0062_generate_data(
    p_rows IN NUMBER DEFAULT 10,
    p_prefix IN VARCHAR2 DEFAULT 'Value-'
) RETURN SCT_0062_data_tab_type PIPELINED IS
    v_id NUMBER;
    v_value VARCHAR2(100);
    v_date DATE;
BEGIN
    -- 指定された行数分のデータを生成
    FOR i IN 1..p_rows LOOP
        -- DUAL テーブルを使用してデータを生成
        SELECT
            i,
            p_prefix || TO_CHAR(i, 'FM000'),
            SYSDATE + i/24 -- 1時間ずつ増加
        INTO
            v_id,
            v_value,
            v_date
        FROM DUAL;

        -- 生成したデータを行としてパイプライン
        PIPE ROW(SCT_0062_data_obj_type(v_id, v_value, v_date));
    END LOOP;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        RETURN;
END SCT_0062_generate_data;
/

-- パイプライン化されたテーブル関数を使用するプロシージャ
CREATE OR REPLACE PROCEDURE SCT_0062_process_data(
    p_row_count IN NUMBER DEFAULT 10,
    p_prefix IN VARCHAR2 DEFAULT 'Item-',
    p_action IN VARCHAR2 DEFAULT 'DISPLAY'  -- 'DISPLAY', 'SUMMARIZE', 'EXPORT'
) AS
    -- 変数宣言
    v_total_count NUMBER := 0;
    v_sum_ids NUMBER := 0;
    v_dummy VARCHAR2(1);
BEGIN
    DBMS_OUTPUT.PUT_LINE('データ処理を開始します...');
    DBMS_OUTPUT.PUT_LINE('行数: ' || p_row_count);
    DBMS_OUTPUT.PUT_LINE('プレフィックス: ' || p_prefix);

    -- DUAL テーブルを使用して処理開始時刻を取得
    SELECT 'X' INTO v_dummy FROM DUAL;

    -- アクションに基づいて処理
    CASE UPPER(p_action)
        WHEN 'DISPLAY' THEN
            -- データを表示
            DBMS_OUTPUT.PUT_LINE('-----------------------------------');
            DBMS_OUTPUT.PUT_LINE('ID  | 値                 | 日時');
            DBMS_OUTPUT.PUT_LINE('-----------------------------------');

            -- パイプライン化されたテーブル関数を使用
            FOR data_rec IN (
                SELECT * FROM TABLE(SCT_0062_generate_data(p_row_count, p_prefix))
            ) LOOP
                DBMS_OUTPUT.PUT_LINE(
                    LPAD(data_rec.id, 3) || ' | ' ||
                    RPAD(data_rec.value, 20) || ' | ' ||
                    TO_CHAR(data_rec.calc_date, 'YYYY-MM-DD HH24:MI:SS')
                );

                v_total_count := v_total_count + 1;
                v_sum_ids := v_sum_ids + data_rec.id;
            END LOOP;

	            DBMS_OUTPUT.PUT_LINE('-----------------------------------');
            DBMS_OUTPUT.PUT_LINE('処理された行数: ' || v_total_count);

        WHEN 'SUMMARIZE' THEN
            -- データの要約を表示
            DBMS_OUTPUT.PUT_LINE('データ要約を生成中...');

            -- パイプライン化されたテーブル関数を使用してデータを集計
            FOR data_rec IN (
                SELECT * FROM TABLE(SCT_0062_generate_data(p_row_count, p_prefix))
            ) LOOP
                v_total_count := v_total_count + 1;
                v_sum_ids := v_sum_ids + data_rec.id;
            END LOOP;

            -- DUAL テーブルを使用して平均を計算
            DECLARE
                v_average NUMBER;
            BEGIN
                SELECT
                    CASE
                        WHEN v_total_count > 0 THEN v_sum_ids / v_total_count
                        ELSE 0
                    END
                INTO v_average
                FROM DUAL;

                DBMS_OUTPUT.PUT_LINE('-----------------------------------');
                DBMS_OUTPUT.PUT_LINE('総行数: ' || v_total_count);
                DBMS_OUTPUT.PUT_LINE('ID合計: ' || v_sum_ids);
                DBMS_OUTPUT.PUT_LINE('ID平均: ' || TO_CHAR(v_average, '999.99'));
            END;

	        WHEN 'EXPORT' THEN
            -- データのエクスポート（シミュレーション）
            DBMS_OUTPUT.PUT_LINE('データエクスポートをシミュレート中...');

            -- エクスポートヘッダー
            DBMS_OUTPUT.PUT_LINE('ID,VALUE,CALC_DATE');

            -- パイプライン化されたテーブル関数を使用してデータをエクスポート
            FOR data_rec IN (
                SELECT * FROM TABLE(SCT_0062_generate_data(p_row_count, p_prefix))
            ) LOOP
                -- CSV形式で出力
                DBMS_OUTPUT.PUT_LINE(
                    data_rec.id || ',"' ||
                    data_rec.value || '",' ||
                    TO_CHAR(data_rec.calc_date, 'YYYY-MM-DD HH24:MI:SS')
                );

                v_total_count := v_total_count + 1;
            END LOOP;

            DBMS_OUTPUT.PUT_LINE('-----------------------------------');
            DBMS_OUTPUT.PUT_LINE(v_total_count || ' 行がエクスポートされました');

        ELSE
            -- DUAL テーブルを使用してエラーメッセージを生成
            SELECT 'X' INTO v_dummy FROM DUAL;
            DBMS_OUTPUT.PUT_LINE('不明なアクション: ' || p_action);
            DBMS_OUTPUT.PUT_LINE('有効なアクション: DISPLAY, SUMMARIZE, EXPORT');
    END CASE;

    -- DUAL テーブルを使用して処理終了時刻を取得
    DECLARE
        v_end_time VARCHAR2(30);
    BEGIN
        SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
        INTO v_end_time
        FROM DUAL;

        DBMS_OUTPUT.PUT_LINE('処理が完了しました。時刻: ' || v_end_time);
    END;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0062_process_data;
/
