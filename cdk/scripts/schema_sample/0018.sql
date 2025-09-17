CREATE OR REPLACE PROCEDURE SCT_0018_ORACLE_HINTS_SAMPLE
IS
    v_result NUMBER;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_execution_time INTERVAL DAY TO SECOND;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== Oracleヒント句のサンプル =====');

    -- 1. ALL_ROWS ヒント（コストベースオプティマイザに全行取得の最適化を指示）
    DBMS_OUTPUT.PUT_LINE('1. ALL_ROWSヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ ALL_ROWS */ COUNT(*)
    INTO v_result
    FROM (
        SELECT * FROM DUAL
        UNION ALL
        SELECT * FROM DUAL
        UNION ALL
        SELECT * FROM DUAL
    );

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 2. FIRST_ROWS ヒント（最初の数行を高速に取得するよう最適化）
    DBMS_OUTPUT.PUT_LINE('2. FIRST_ROWSヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ FIRST_ROWS(10) */ DUMMY
    INTO v_result
    FROM DUAL;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 3. FULL ヒント（テーブルのフルスキャンを強制）
    DBMS_OUTPUT.PUT_LINE('3. FULLヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ FULL(d) */ DUMMY
    INTO v_result
    FROM DUAL d;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 4. CACHE ヒント（テーブルをバッファキャッシュに保持）
    DBMS_OUTPUT.PUT_LINE('4. CACHEヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ CACHE(d) */ DUMMY
    INTO v_result
    FROM DUAL d;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 5. NOCACHE ヒント（テーブルをバッファキャッシュに保持しない）
    DBMS_OUTPUT.PUT_LINE('5. NOCACHEヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ NOCACHE(d) */ DUMMY
    INTO v_result
    FROM DUAL d;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 6. PARALLEL ヒント（並列実行を指定）
    DBMS_OUTPUT.PUT_LINE('6. PARALLELヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ PARALLEL(d, 2) */ DUMMY
    INTO v_result
    FROM DUAL d;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 7. NOPARALLEL ヒント（並列実行を無効化）
    DBMS_OUTPUT.PUT_LINE('7. NOPARALLELヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ NOPARALLEL(d) */ DUMMY
    INTO v_result
    FROM DUAL d;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 8. DRIVING_SITE ヒント（分散クエリの実行場所を指定）
    DBMS_OUTPUT.PUT_LINE('8. DRIVING_SITEヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ DRIVING_SITE(d) */ DUMMY
    INTO v_result
    FROM DUAL d;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 9. APPEND ヒント（ダイレクトパスインサートを使用）
    DBMS_OUTPUT.PUT_LINE('9. APPENDヒントの例:');
    v_start_time := SYSTIMESTAMP;

    EXECUTE IMMEDIATE 'INSERT /*+ APPEND */ INTO DUAL SELECT ''X'' FROM DUAL';

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 10. RESULT_CACHE ヒント（結果をキャッシュ）
    DBMS_OUTPUT.PUT_LINE('10. RESULT_CACHEヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ RESULT_CACHE */ DUMMY
    INTO v_result
    FROM DUAL;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 11. NO_RESULT_CACHE ヒント（結果のキャッシュを無効化）
    DBMS_OUTPUT.PUT_LINE('11. NO_RESULT_CACHEヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ NO_RESULT_CACHE */ DUMMY
    INTO v_result
    FROM DUAL;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    -- 12. GATHER_PLAN_STATISTICS ヒント（実行計画の統計情報を収集）
    DBMS_OUTPUT.PUT_LINE('12. GATHER_PLAN_STATISTICSヒントの例:');
    v_start_time := SYSTIMESTAMP;

    SELECT /*+ GATHER_PLAN_STATISTICS */ DUMMY
    INTO v_result
    FROM DUAL;

    v_end_time := SYSTIMESTAMP;
    v_execution_time := v_end_time - v_start_time;

    DBMS_OUTPUT.PUT_LINE('  結果: ' || v_result);
    DBMS_OUTPUT.PUT_LINE('  実行時間: ' || v_execution_time);
    DBMS_OUTPUT.PUT_LINE('');

    DBMS_OUTPUT.PUT_LINE('===== ヒント句のサンプル実行完了 =====');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0018_ORACLE_HINTS_SAMPLE;
/
