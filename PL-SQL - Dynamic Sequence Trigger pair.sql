declare
        --Our objective is to : Retrieving all primary key columns with number data type
        
        --Declaring the (primary key columns) cursor
        cursor all_primary_cols is
                SELECT DISTINCT USER_CONS_COLUMNS.COLUMN_NAME, USER_CONS_COLUMNS.TABLE_NAME, USER_TAB_COLUMNS.DATA_TYPE, USER_CONSTRAINTS.CONSTRAINT_TYPE
                FROM USER_TAB_COLUMNS, USER_CONSTRAINTS, USER_CONS_COLUMNS
                WHERE USER_CONSTRAINTS.CONSTRAINT_NAME = USER_CONS_COLUMNS.CONSTRAINT_NAME AND USER_TAB_COLUMNS.COLUMN_NAME = USER_CONS_COLUMNS.COLUMN_NAME
                AND USER_CONSTRAINTS.CONSTRAINT_TYPE = 'P' AND USER_TAB_COLUMNS.DATA_TYPE = 'NUMBER';
                
     --Declaring another Cursor to retrieve all old sequences to delete them           
    CURSOR V_SEQ_CUR
      IS SELECT  SEQUENCE_NAME FROM USER_SEQUENCES;

--Declaring a variable to store the maximum (last) number of the column to start the sequence after it.
v_max number;

begin
    
    --Looping over all old sequences to drop it
    FOR V_REC IN V_SEQ_CUR LOOP
          EXECUTE IMMEDIATE 'DROP SEQUENCE ' || V_REC.SEQUENCE_NAME;
    END LOOP;
 

FOR rec IN all_primary_cols LOOP --Looping over the primary key columns to create sequence for them
EXECUTE IMMEDIATE 'select max(' ||rec.COLUMN_NAME || ' + 1) from ' || rec.TABLE_NAME into v_max; --Inserting the last number of the column into the variable, I used dynamic sql so I can use sql inside a PLSQL block.

EXECUTE IMMEDIATE 'CREATE SEQUENCE ' ||  rec.TABLE_NAME || '_SEQ' || --Creating a sequence by the table name
' START WITH ' || v_max || --Starting with the number after maximum value
 ' INCREMENT BY  1';

EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || rec.TABLE_NAME || '_TRG_SEQ' || --Creating a trigger for the selected table 
' BEFORE INSERT 
ON ' || rec.TABLE_NAME ||
' FOR EACH ROW
BEGIN 
  :new.' || rec.COLUMN_NAME || ' := ' ||  rec.TABLE_NAME || '_SEQ' || '.nextval;
END ;';

end loop;
end;
show errors