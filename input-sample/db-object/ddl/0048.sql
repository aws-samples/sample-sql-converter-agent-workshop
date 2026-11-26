CREATE OR REPLACE PROCEDURE SCT_0048_CONNECT_BY_NOCYCLE_SAMPLE
IS
    v_level NUMBER;
    v_path VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== CONNECT BY NOCYCLEのサンプル =====');
    DBMS_OUTPUT.PUT_LINE('1. 数値シーケンスの生成:');

    -- 1から10までの数値シーケンスを生成
    FOR rec IN (
        SELECT LEVEL AS num
        FROM DUAL
        CONNECT BY LEVEL <= 10
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || rec.num);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. 日付シーケンスの生成:');

    -- 7日間の日付シーケンスを生成
    FOR rec IN (
        SELECT SYSDATE + (LEVEL - 1) AS date_value,
               TO_CHAR(SYSDATE + (LEVEL - 1), 'YYYY-MM-DD') AS date_str
        FROM DUAL
        CONNECT BY LEVEL <= 7
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || rec.date_str);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. 階層構造の生成（NOCYCLEの使用）:');

    -- 階層構造を生成（循環参照を防ぐためにNOCYCLEを使用）
    FOR rec IN (
        SELECT LEVEL AS depth,
               LPAD(' ', (LEVEL-1)*2) || 'Node ' || LEVEL AS node_name,
               SYS_CONNECT_BY_PATH(LEVEL, '/') AS path
        FROM DUAL
        CONNECT BY NOCYCLE LEVEL <= 5
        AND PRIOR LEVEL <> 3  -- 循環参照を作成（NOCYCLEがなければ無限ループになる）
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  深さ: ' || rec.depth || ', ノード: ' || rec.node_name || ', パス: ' || rec.path);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. 階層レベルと位置情報:');

    -- 階層レベルと位置情報を表示
    FOR rec IN (
        SELECT LEVEL,
               CONNECT_BY_ROOT LEVEL AS root_level,
               CONNECT_BY_ISLEAF AS is_leaf,
               SYS_CONNECT_BY_PATH(LEVEL, '->') AS path
        FROM DUAL
        CONNECT BY LEVEL <= 5
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  レベル: ' || rec.LEVEL ||
                           ', ルート: ' || rec.root_level ||
                           ', リーフ?: ' || rec.is_leaf ||
                           ', パス: ' || rec.path);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('5. 複雑な階層構造（NOCYCLEの重要性）:');

    -- 複雑な階層構造を生成（循環参照を含む）
    FOR rec IN (
        WITH hierarchy_data AS (
            SELECT 1 AS id, NULL AS parent_id, 'Root' AS name FROM DUAL
            UNION ALL
            SELECT 2, 1, 'Child 1' FROM DUAL
            UNION ALL
            SELECT 3, 1, 'Child 2' FROM DUAL
            UNION ALL
            SELECT 4, 2, 'Grandchild 1' FROM DUAL
            UNION ALL
            SELECT 5, 3, 'Grandchild 2' FROM DUAL
            UNION ALL
            SELECT 6, 4, 'Great-Grandchild' FROM DUAL
            UNION ALL
            SELECT 7, 6, 'Circular Ref' FROM DUAL
            UNION ALL
            SELECT 8, 7, 'Deep Node' FROM DUAL
            UNION ALL
            SELECT 9, 8, 'Deeper Node' FROM DUAL
            UNION ALL
            SELECT 10, 9, 'Deepest Node' FROM DUAL
            UNION ALL
            SELECT 11, 10, 'Circular Back' FROM DUAL
            UNION ALL
            SELECT 12, 11, 'Final Node' FROM DUAL
        )
        SELECT LEVEL,
               LPAD(' ', (LEVEL-1)*2) || name AS hierarchy_name,
               SYS_CONNECT_BY_PATH(name, ' -> ') AS path,
               CONNECT_BY_ISCYCLE AS is_cycle
        FROM hierarchy_data
        START WITH id = 1
        CONNECT BY NOCYCLE PRIOR id = parent_id
        ORDER SIBLINGS BY id
    ) LOOP
        v_path := CASE WHEN LENGTH(rec.path) > 80
                       THEN SUBSTR(rec.path, 1, 77) || '...'
                       ELSE rec.path END;

        DBMS_OUTPUT.PUT_LINE('  レベル: ' || rec.LEVEL ||
                           ', 名前: ' || rec.hierarchy_name ||
                           ', 循環?: ' || rec.is_cycle ||
                           ', パス: ' || v_path);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('6. 数値の階乗計算:');

    -- 階乗の計算（1から10まで）
    FOR rec IN (
        SELECT LEVEL AS n,
               EXP(SUM(LN(LEVEL)) OVER (ORDER BY LEVEL)) AS factorial
        FROM DUAL
        CONNECT BY LEVEL <= 10
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || rec.n || '! = ' || rec.factorial);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===== サンプル実行完了 =====');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
END SCT_0048_CONNECT_BY_NOCYCLE_SAMPLE;
/
