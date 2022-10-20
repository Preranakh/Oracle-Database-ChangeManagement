--Modifying the ASP_NET_USERS to add the unique key
ALTER TABLE ASP_NET_USERS
ADD CONSTRAINT ASP_NET_USERS_UK1 UNIQUE 
(
  USER_NAME 
)
ENABLE;
-------------------------------------------
--Creating the School_User table with necessary constraints

CREATE TABLE SCHOOL_USER 
(
  USER_NAME NVARCHAR2(256) NOT NULL 
, SCHOOL_ID NUMBER(8, 0) NOT NULL 
, CONSTRAINT SCHOOL_USER_PK PRIMARY KEY 
  (
    USER_NAME 
  , SCHOOL_ID 
  )
  ENABLE 
);
-----------------------------------------------
--adding the foreign keys in the school_user table

ALTER TABLE SCHOOL_USER
ADD CONSTRAINT SCHOOL_USER_FK1 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;

ALTER TABLE SCHOOL_USER
ADD CONSTRAINT SCHOOL_USER_FK2 FOREIGN KEY
(
  USER_NAME 
)
REFERENCES ASP_NET_USERS
(
  USER_NAME 
)
ENABLE;
----------------------------------------------------------
--UPDATING rows IN ASP_NET_USERS_TABLE after logging in from the frontend

UPDATE ASP_NET_USERS
  SET USER_NAME = 'USER2'
 ,normalized_user_name= 'USER2'
  WHERE EMAIL = 'khatiwadaprerana@gmail.com';
----------------------------------------------------------
--Inserting rows into the school Table

Insert into SCHOOL_USER(USER_NAME, SCHOOL_ID) values 
('USER2',1);
------------------------------
--Creating the security Package for the row level Security

CREATE OR REPLACE PACKAGE security_package AS
  FUNCTION user_data_insert_security(owner VARCHAR2, objname VARCHAR2)
    RETURN VARCHAR2;
  
  FUNCTION user_data_select_security(owner VARCHAR2, objname VARCHAR2)
    RETURN VARCHAR2;
      
  FUNCTION user_data_update_security(owner VARCHAR2, objname VARCHAR2)
    RETURN VARCHAR2;
      
  FUNCTION user_data_delete_security(owner VARCHAR2, objname VARCHAR2)
    RETURN VARCHAR2;

END security_package;
/


CREATE OR REPLACE PACKAGE BODY security_package IS
--select
  FUNCTION user_data_select_security(owner VARCHAR2, objname VARCHAR2) RETURN 
VARCHAR2 IS
    predicate VARCHAR2(2000);
  BEGIN
    predicate := '1=2';
    IF (SYS_CONTEXT('USERENV','SESSION_USER') = 'C##_UD_PRERANAK') THEN
      predicate := NULL;
    ELSE 
      predicate := 'SCHOOL_ID in ' || SYS_CONTEXT('C##SCHOOL_CONTEXT','SCHOOL_IDS');
    END IF;
    RETURN predicate;
  END user_data_select_security;
  --insert
  FUNCTION user_data_insert_security(owner VARCHAR2, objname VARCHAR2) RETURN 
VARCHAR2 IS
    predicate VARCHAR2(2000);
  BEGIN
    predicate := '1=2';
    IF (SYS_CONTEXT('USERENV','SESSION_USER') = 'C##_UD_PRERANAK') THEN
      predicate := NULL;
    ELSE 
       predicate := 'SCHOOL_ID in ' || SYS_CONTEXT('C##SCHOOL_CONTEXT','SCHOOL_IDS');
    END IF;
    RETURN Predicate;
  END user_data_insert_security;

  --update
    FUNCTION user_data_update_security(owner VARCHAR2, objname VARCHAR2) RETURN 
VARCHAR2 IS
    predicate VARCHAR2(2000);
  BEGIN
    predicate := '1=2';
    IF (SYS_CONTEXT('USERENV','SESSION_USER') = 'C##_UD_PRERANAK') THEN
      predicate := NULL;
    ELSE 
       predicate := 'SCHOOL_ID in ' || SYS_CONTEXT('C##SCHOOL_CONTEXT','SCHOOL_IDS');
    END IF;
    RETURN Predicate;
  END user_data_update_security;

  --delete
    FUNCTION user_data_delete_security(owner VARCHAR2, objname VARCHAR2) RETURN 
VARCHAR2 IS
    predicate VARCHAR2(2000);
  BEGIN
    predicate := '1=2';
    IF (SYS_CONTEXT('USERENV','SESSION_USER') = 'C##_UD_PRERANAK') THEN
      predicate := NULL;
    ELSE 
       predicate := 'SCHOOL_ID in ' || SYS_CONTEXT('C##SCHOOL_CONTEXT','SCHOOL_IDS');
    END IF;
    RETURN Predicate;
  END user_data_delete_security;

END security_package;
/

---------------------------------------------------------------------
GRANT EXECUTE ON C##_UD_PRERANAK.security_package TO PUBLIC;
/
----------------------------------------------------------------------
--providing grant to all the tables
DECLARE
    v_sql VARCHAR2(2000);
BEGIN
    FOR tabname IN (
        SELECT
            ut.table_name
        FROM
                 user_tables ut
            INNER JOIN (
                SELECT
                    table_name
                FROM
                    user_tab_cols
                WHERE
                    column_name = 'SCHOOL_ID'
            ) uc ON ut.table_name = uc.table_name
    ) LOOP
        v_sql := 'GRANT SELECT, UPDATE, INSERT, DELETE ON '
                 || tabname.table_name
                 || ' TO C##CISC437_STUDENT_ROLE';
        EXECUTE IMMEDIATE v_sql;
    END LOOP;
END;
/
------------------------------------------------
--adding the DBMS_RLS.ADD_POLICY on each table

DECLARE
CURSOR C_POLICY IS 
SELECT UT.TABLE_NAME
FROM USER_TABLES UT
INNER JOIN USER_TAB_COLS UTC
ON UT.TABLE_NAME = UTC.TABLE_NAME
where UT.TABLE_NAME not in 'SCHOOL_USER'
AND UTC.COLUMN_NAME = 'SCHOOL_ID';
V_SQL VARCHAR2(2000);

V_ACTION VARCHAR2(10);
V_IDX NUMBER(1);
V_POLICY VARCHAR2(100);
V_CNT NUMBER(1);
BEGIN

    FOR R_POLICY IN C_POLICY
    LOOP
        FOR V_IDX IN 1..4 
        LOOP
        IF V_IDX = 1 THEN V_ACTION := 'INSERT'; END IF;
        IF V_IDX = 2 THEN V_ACTION := 'UPDATE'; END IF;
        IF V_IDX = 3 THEN V_ACTION := 'SELECT'; END IF;
        IF V_IDX = 4 THEN V_ACTION := 'DELETE'; END IF;
        
        V_POLICY := R_POLICY.TABLE_NAME || '_' || V_ACTION || '_POLICY';
        SELECT COUNT(*) INTO V_CNT FROM USER_POLICIES
        WHERE POLICY_NAME = V_POLICY;    
        IF V_CNT > 0 THEN
            V_SQL := 'BEGIN DBMS_RLS.DROP_POLICY(' || '''' || USER || '''' || ',' || '''' || R_POLICY.TABLE_NAME || '''' || ',' || '''' || V_POLICY || '''' || '); END;';
            EXECUTE IMMEDIATE V_SQL;           
        END IF;
        V_SQL := 'BEGIN ';
        V_SQL := V_SQL || ' DBMS_RLS.ADD_POLICY(' || '''' || USER || '''' || ',' || '''' || R_POLICY.TABLE_NAME || '''' || ',' || '''' || R_POLICY.TABLE_NAME || '_' || V_ACTION || '_POLICY' || '''' || ',';
        V_SQL := V_SQL || '''' || USER || '''' || ',';
        V_SQL := V_SQL || '''' || 'SECURITY_PACKAGE.USER_DATA_' || V_ACTION || '_SECURITY' || '''' || ',';
        V_SQL := V_SQL || '''' || V_ACTION || '''' || ',TRUE);';
        V_SQL := V_SQL || 'END;';
        EXECUTE IMMEDIATE V_SQL;
        END LOOP;
    END LOOP;
END;
/


