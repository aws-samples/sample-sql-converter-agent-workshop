-- テーブルの作成
CREATE TABLE T_0019_PRODUCTS (
    PRODUCT_ID NUMBER PRIMARY KEY,
    PRODUCT_NAME VARCHAR2(100),
    PRICE NUMBER(10,2),
    STOCK_QUANTITY NUMBER,
    LAST_UPDATE_DATE DATE DEFAULT SYSDATE
);

CREATE TABLE T_0019_ORDERS (
    ORDER_ID NUMBER PRIMARY KEY,
    PRODUCT_ID NUMBER,
    ORDER_QUANTITY NUMBER,
    ORDER_DATE DATE DEFAULT SYSDATE,
    FOREIGN KEY (PRODUCT_ID) REFERENCES T_0019_PRODUCTS(PRODUCT_ID)
);

CREATE OR REPLACE PROCEDURE SCT_0019_PROCESS_ORDERS(
    p_batch_size IN NUMBER DEFAULT 100
)
IS
    -- 注文データを格納するレコード型とコレクション型
    TYPE t_order_rec IS RECORD (
        product_id T_0019_PRODUCTS.PRODUCT_ID%TYPE,
        order_quantity T_0019_ORDERS.ORDER_QUANTITY%TYPE
    );
    TYPE t_order_tab IS TABLE OF t_order_rec;

    -- 処理する注文データ
    v_orders t_order_tab;

    -- 注文IDを格納するコレクション
    TYPE t_order_id_tab IS TABLE OF T_0019_ORDERS.ORDER_ID%TYPE;
    v_order_ids t_order_id_tab;

    -- 次の注文ID
    v_next_order_id NUMBER;

    -- カーソルの定義
    CURSOR c_products IS
        SELECT PRODUCT_ID, PRODUCT_NAME, STOCK_QUANTITY
        FROM T_0019_PRODUCTS
        WHERE STOCK_QUANTITY > 0
        ORDER BY PRODUCT_ID;

    -- 商品データを格納するコレクション型
    TYPE t_product_id_tab IS TABLE OF T_0019_PRODUCTS.PRODUCT_ID%TYPE;
    TYPE t_product_name_tab IS TABLE OF T_0019_PRODUCTS.PRODUCT_NAME%TYPE;
    TYPE t_stock_qty_tab IS TABLE OF T_0019_PRODUCTS.STOCK_QUANTITY%TYPE;

    -- 商品データを格納するコレクション変数
    v_product_ids t_product_id_tab;
    v_product_names t_product_name_tab;
    v_stock_qtys t_stock_qty_tab;

    -- 成功した注文数
    v_success_count NUMBER := 0;

    -- 在庫不足で失敗した注文数
    v_failed_count NUMBER := 0;
BEGIN
    -- 現在の最大注文IDを取得
    SELECT NVL(MAX(ORDER_ID), 0) INTO v_next_order_id FROM T_0019_ORDERS;
    v_next_order_id := v_next_order_id + 1;

    -- カーソルから商品データを一括取得
    OPEN c_products;
    FETCH c_products BULK COLLECT INTO v_product_ids, v_product_names, v_stock_qtys
    LIMIT p_batch_size;
    CLOSE c_products;

    DBMS_OUTPUT.PUT_LINE('取得した商品数: ' || v_product_ids.COUNT);

    -- 注文データを生成（デモ用）
    v_orders := t_order_tab();
    v_orders.EXTEND(v_product_ids.COUNT);
    v_order_ids := t_order_id_tab();
    v_order_ids.EXTEND(v_product_ids.COUNT);

    FOR i IN 1..v_product_ids.COUNT LOOP
        -- 注文数量はランダムに生成（在庫の10%～50%）
        v_orders(i).product_id := v_product_ids(i);
        v_orders(i).order_quantity := FLOOR(v_stock_qtys(i) * (DBMS_RANDOM.VALUE(10, 50) / 100));
        v_order_ids(i) := v_next_order_id + i - 1;

        DBMS_OUTPUT.PUT_LINE('商品ID: ' || v_product_ids(i) ||
                           ', 商品名: ' || v_product_names(i) ||
                           ', 在庫数: ' || v_stock_qtys(i) ||
                           ', 注文数: ' || v_orders(i).order_quantity);
    END LOOP;

    -- 注文データを一括挿入
    FORALL i IN 1..v_orders.COUNT
        INSERT INTO T_0019_ORDERS (ORDER_ID, PRODUCT_ID, ORDER_QUANTITY)
        VALUES (v_order_ids(i), v_orders(i).product_id, v_orders(i).order_quantity);

    -- BULK_ROWCOUNTを使用して挿入結果を確認
    DBMS_OUTPUT.PUT_LINE('注文挿入結果:');
    FOR i IN 1..v_orders.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('注文 ' || i || ': ' || SQL%BULK_ROWCOUNT(i) || ' 行挿入');
    END LOOP;

    -- 在庫を更新（注文数を減算）
    BEGIN
        FORALL i IN 1..v_orders.COUNT SAVE EXCEPTIONS
            UPDATE T_0019_PRODUCTS
            SET STOCK_QUANTITY = STOCK_QUANTITY - v_orders(i).order_quantity,
                LAST_UPDATE_DATE = SYSDATE
            WHERE PRODUCT_ID = v_orders(i).product_id
            AND STOCK_QUANTITY >= v_orders(i).order_quantity;

        -- BULK_ROWCOUNTを使用して更新結果を確認
        DBMS_OUTPUT.PUT_LINE('在庫更新結果:');
        FOR i IN 1..v_orders.COUNT LOOP
            IF SQL%BULK_ROWCOUNT(i) > 0 THEN
                DBMS_OUTPUT.PUT_LINE('商品ID ' || v_orders(i).product_id ||
                                   ': 在庫を ' || v_orders(i).order_quantity || ' 減少');
                v_success_count := v_success_count + 1;
            ELSE
                DBMS_OUTPUT.PUT_LINE('商品ID ' || v_orders(i).product_id ||
                                   ': 在庫不足のため更新できませんでした');
                v_failed_count := v_failed_count + 1;
            END IF;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('在庫更新中にエラーが発生しました');
            DBMS_OUTPUT.PUT_LINE('エラー数: ' || SQL%BULK_EXCEPTIONS.COUNT);
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE(
                    'エラー ' || i || ' (インデックス ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX || '): ' ||
                    SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE)
                );
                v_failed_count := v_failed_count + 1;
            END LOOP;
    END;

    -- 在庫不足の注文を削除
    FORALL i IN 1..v_orders.COUNT
        DELETE FROM T_0019_ORDERS
        WHERE ORDER_ID = v_order_ids(i)
        AND NOT EXISTS (
            SELECT 1
            FROM T_0019_PRODUCTS
            WHERE PRODUCT_ID = v_orders(i).product_id
            AND STOCK_QUANTITY >= v_orders(i).order_quantity
        );

    -- BULK_ROWCOUNTを使用して削除結果を確認
    DBMS_OUTPUT.PUT_LINE('注文削除結果:');
    FOR i IN 1..v_orders.COUNT LOOP
        IF SQL%BULK_ROWCOUNT(i) > 0 THEN
            DBMS_OUTPUT.PUT_LINE('注文ID ' || v_order_ids(i) || ': 在庫不足のため削除');
        END IF;
    END LOOP;

    -- 処理結果の要約
    DBMS_OUTPUT.PUT_LINE('処理結果要約:');
    DBMS_OUTPUT.PUT_LINE('成功した注文数: ' || v_success_count);
    DBMS_OUTPUT.PUT_LINE('失敗した注文数: ' || v_failed_count);

    -- 更新後の在庫状況を確認
    DBMS_OUTPUT.PUT_LINE('更新後の在庫状況:');
    FOR rec IN (SELECT PRODUCT_ID, PRODUCT_NAME, STOCK_QUANTITY
                FROM T_0019_PRODUCTS
                ORDER BY PRODUCT_ID) LOOP
        DBMS_OUTPUT.PUT_LINE('商品ID: ' || rec.PRODUCT_ID ||
                           ', 商品名: ' || rec.PRODUCT_NAME ||
                           ', 在庫数: ' || rec.STOCK_QUANTITY);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('すべての処理が完了しました');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('エラーが発生しました: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END SCT_0019_PROCESS_ORDERS;
/
