CREATE OR REPLACE PROCEDURE SCT_0071_cursor_sync_issue_demo AS
    -- メインプロシージャのカーソル
    CURSOR main_cursor IS
        SELECT 'MAIN_' || LEVEL AS data
        FROM DUAL
        CONNECT BY LEVEL <= 3;

    v_main_rec main_cursor%ROWTYPE;

    -- 自律トランザクションを持つネストされたプロシージャ
    PROCEDURE autonomous_proc(p_value IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        -- 自律トランザクション内でメインカーソルを参照しようとする
        -- これが同期の問題を引き起こす
    BEGIN
        -- 問題のあるコード: 自律トランザクション内から外部カーソルの状態に依存
        IF main_cursor%ISOPEN THEN
            -- 外部カーソルが開いている場合の処理
            DBMS_OUTPUT.PUT_LINE('自律トランザクション内: 外部カーソルは開いています');

            -- 問題のあるコード: 自律トランザクション内から外部カーソルを操作
            FETCH main_cursor INTO v_main_rec;

            IF main_cursor%FOUND THEN
                DBMS_OUTPUT.PUT_LINE('自律トランザクション内: 取得した値 = ' || v_main_rec.data);
            ELSE
                DBMS_OUTPUT.PUT_LINE('自律トランザクション内: これ以上データがありません');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('自律トランザクション内: 外部カーソルは閉じています');
        END IF;

        -- 自律トランザクションをコミット
        COMMIT;
    END autonomous_proc;

BEGIN
    DBMS_OUTPUT.PUT_LINE('メインプロシージャ開始');

    -- メインカーソルを開く
    OPEN main_cursor;

    -- メインカーソルをループ処理
    LOOP
        FETCH main_cursor INTO v_main_rec;
        EXIT WHEN main_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('メイン処理: ' || v_main_rec.data);

        -- 自律トランザクションプロシージャを呼び出す
        autonomous_proc(v_main_rec.data);

        -- カーソル状態の確認
        IF main_cursor%ISOPEN THEN
            DBMS_OUTPUT.PUT_LINE('メイン処理: カーソルはまだ開いています');
        ELSE
            DBMS_OUTPUT.PUT_LINE('メイン処理: カーソルが閉じられました！');
            -- カーソルが閉じられた場合は再度開く
            OPEN main_cursor;
        END IF;
    END LOOP;

    -- メインカーソルを閉じる
    CLOSE main_cursor;

    DBMS_OUTPUT.PUT_LINE('メインプロシージャ終了');
EXCEPTION
    WHEN OTHERS THEN
        IF main_cursor%ISOPEN THEN
            CLOSE main_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0071_cursor_sync_issue_demo;
/
