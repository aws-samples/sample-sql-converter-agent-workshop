CREATE OR REPLACE PROCEDURE SCT_0039_create_basic_job (
    p_job_name IN VARCHAR2,
    p_start_date IN TIMESTAMP DEFAULT SYSTIMESTAMP,
    p_repeat_interval IN VARCHAR2 DEFAULT 'FREQ=DAILY; INTERVAL=1'
) AS
BEGIN
    -- 既存のジョブがあれば削除
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(
            job_name => p_job_name,
            force => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- ジョブが存在しない場合は無視
    END;

    -- 新しいジョブを作成
    DBMS_SCHEDULER.CREATE_JOB(
        job_name => p_job_name,
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN DBMS_OUTPUT.PUT_LINE(''ジョブ実行: '' || TO_CHAR(SYSTIMESTAMP, ''YYYY-MM-DD HH24:MI:SS.FF'')); END;',
        start_date => p_start_date,
        repeat_interval => p_repeat_interval,
        enabled => TRUE,
        comments => '基本的なスケジュールジョブ'
    );

    DBMS_OUTPUT.PUT_LINE('ジョブ ' || p_job_name || ' が作成されました');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END;
/
