# Oracle PL SQL Dynamic Sequence Trigger pair 

A PL SQL script for dynamic Sequence / Trigger pair script for all tables in the schema.

### Requirements: 
+ Using PLSQL Dynamic SQL create dynamic Sequence / Trigger pair for each table in your schema.
+ Drop all sequences and replace all triggers dynamically / your sequence start value should start with the max id + 1 for each table according to it's data - increment by 1 for each table.


### Code Walkthrough:

+ Retrieving all primary key columns with number data type.
+ Declaring the (primary key columns) cursor.

```
cursor all_primary_cols is
SELECT DISTINCT USER_CONS_COLUMNS.COLUMN_NAME, USER_CONS_COLUMNS.TABLE_NAME, USER_TAB_COLUMNS.DATA_TYPE, USER_CONSTRAINTS.CONSTRAINT_TYPE
FROM USER_TAB_COLUMNS, USER_CONSTRAINTS, USER_CONS_COLUMNS
WHERE USER_CONSTRAINTS.CONSTRAINT_NAME = USER_CONS_COLUMNS.CONSTRAINT_NAME AND USER_TAB_COLUMNS.COLUMN_NAME = USER_CONS_COLUMNS.COLUMN_NAME
AND USER_CONSTRAINTS.CONSTRAINT_TYPE = 'P' AND USER_TAB_COLUMNS.DATA_TYPE = 'NUMBER';
```

+ Declaring another Cursor to retrieve all old sequences to delete them.
```
cursor all_primary_cols is
CURSOR V_SEQ_CUR
IS SELECT  SEQUENCE_NAME FROM USER_SEQUENCES;
```

+ Declaring a variable to store the maximum (last) number of the column to start the sequence after it.

```
v_max number;
begin
```

+ Looping over all old sequences to drop it

```
v_max number;
begin

    FOR V_REC IN V_SEQ_CUR LOOP
          EXECUTE IMMEDIATE 'DROP SEQUENCE ' || V_REC.SEQUENCE_NAME;
    END LOOP;
```

+ Looping over the primary key columns to create sequence for them


```
FOR rec IN all_primary_cols LOOP 
```

+ Inserting the last number of the column into the variable, I used dynamic sql so I can use sql inside a PLSQL block.


```
EXECUTE IMMEDIATE 'select max(' ||rec.COLUMN_NAME || ' + 1) from ' || rec.TABLE_NAME into v_max; 
```

+ Creating a sequence by the table name
```
EXECUTE IMMEDIATE 'CREATE SEQUENCE ' ||  rec.TABLE_NAME || '_SEQ' || 
```

+ Starting with the number after maximum value
```
' START WITH ' || v_max || 
 ' INCREMENT BY  1';
```
+ Creating a trigger for the selected table 

```
EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || rec.TABLE_NAME || '_TRG_SEQ' || 
' BEFORE INSERT 
ON ' || rec.TABLE_NAME ||
' FOR EACH ROW
BEGIN 
  :new.' || rec.COLUMN_NAME || ' := ' ||  rec.TABLE_NAME || '_SEQ' || '.nextval;
END ;';
```

+ Ending the loop and making sure there's no errors.

```
end loop;
end;
show errors
```





