CREATE TABLE T_0075
   (    "PRODUCT_ID" NUMBER(6,0),
        "WAREHOUSE_ID" NUMBER(6,0) CONSTRAINT "INVENTORY_WAREHOUSE_ID_NN" NOT NULL ENABLE,
        "QUANTITY_ON_HAND" NUMBER(8,0) CONSTRAINT "INVENTORY_QOH_NN" NOT NULL ENABLE,
         CONSTRAINT "INVENTORY_PK" PRIMARY KEY ("PRODUCT_ID", "WAREHOUSE_ID"));

--Procedure with example for all that causes SCT conversion error when running assesment
create or replace
procedure     SCT_0075_FORALL ( min_sleep integer,
                      max_sleep integer) is
      type prodListType is table of number(6,0);
      type warehouseListType is table of number(6,0);
      type noOrderedListType is table of number(6,0);

      prodList prodListType := prodListType();
      warehouseList warehouseListType := warehouseListType();
      noOrderedList noOrderedListType := noOrderedListType();
      AWAITING_PROCESSING integer := 4;

begin
         forall i in prodList.first..prodList.last
          update T_0075
            set quantity_on_hand = quantity_on_hand - noOrderedList(i)
            where product_id = prodList(i)
            and warehouse_id = warehouseList(i);
end;
/
