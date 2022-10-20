--------------------------------------------------------
--  File created - Monday-March-07-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table SCHOOL
--------------------------------------------------------

  CREATE TABLE "SCHOOL" 
   (	"SCHOOL_ID" NUMBER(8,0), 
	"SCHOOL_NAME" VARCHAR2(30 BYTE), 
	"CREATED_BY" VARCHAR2(30 BYTE), 
	"CREATED_DATE" DATE, 
	"MODIFIED_BY" VARCHAR2(30 BYTE), 
	"MODIFIED_DATE" DATE
   ) ;

--------------------------------------------------------
-- Adding SCHOOL_ID column in all other table
--------------------------------------------------------
ALTER TABLE COURSE 
ADD SCHOOL_ID NUMBER(8,0);

ALTER TABLE ENROLLMENT 
ADD SCHOOL_ID NUMBER(8,0);

ALTER TABLE SECTION 
ADD SCHOOL_ID NUMBER(8,0);

ALTER TABLE STUDENT 
ADD SCHOOL_ID NUMBER(8,0);

--------------------------------------------------------
-- Inserting into School table
--------------------------------------------------------
Insert into SCHOOL (SCHOOL_ID,SCHOOL_NAME,CREATED_BY,CREATED_DATE,
MODIFIED_BY,MODIFIED_DATE) values (1,'University of Delaware','DSCHERER',to_date('29-MAR-21','DD-MON-RR'),
'ARISCHER',to_date('05-APR-21','DD-MON-RR'));

--------------------------------------------------------
-- Setting school_id to 1 in all other tables
--------------------------------------------------------
UPDATE COURSE
SET SCHOOL_ID = 1;


UPDATE ENROLLMENT
SET SCHOOL_ID = 1;


UPDATE SECTION
SET SCHOOL_ID = 1;

UPDATE STUDENT
SET SCHOOL_ID = 1;

--------------------------------------------------------
-- Get rid of existing FKs
--------------------------------------------------------

 SET SERVEROUTPUT ON               
BEGIN
    FOR const IN ( SELECT TABLE_NAME, CONSTRAINT_NAME
               FROM USER_CONSTRAINTS
               WHERE CONSTRAINT_TYPE = 'R' /*Foreign Key and Check constraints.*/ )
    LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE '||const.TABLE_NAME ||' DROP CONSTRAINT '||const.CONSTRAINT_NAME;
        DBMS_OUTPUT.PUT_LINE('Dropped constraint '||const.CONSTRAINT_NAME||' of table '||const.TABLE_NAME); 
    END LOOP;
END;
/

--------------------------------------------------------
-- Get rid of existing Pks
--------------------------------------------------------
    
    SET SERVEROUTPUT ON               
BEGIN
    FOR const IN ( SELECT TABLE_NAME, CONSTRAINT_NAME
               FROM USER_CONSTRAINTS
               WHERE CONSTRAINT_TYPE = 'P' /*Primary Key and Check constraints.*/ )
    LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE '||const.TABLE_NAME ||' DROP CONSTRAINT '||const.CONSTRAINT_NAME;
        DBMS_OUTPUT.PUT_LINE('Dropped constraint '||const.CONSTRAINT_NAME||' of table '||const.TABLE_NAME); 
    END LOOP;
END;
/

--------------------------------------------------------
-- ADD NEW COLUMN IN COURSE
--------------------------------------------------------

ALTER TABLE COURSE 
ADD (PREREQUISITE_SCHOOL_ID NUMBER(8, 0) );

update course set PREREQUISITE_SCHOOL_ID=school_id where course_no is not null;

--------------------------------------------------------
-- MAKE ALL THE FIELDS NOT NULL IN SCHOOL TABLE AND SET SCHOOL_ID TO PRIMARY KEY
--------------------------------------------------------
ALTER TABLE SCHOOL  
MODIFY (SCHOOL_ID NOT NULL);

ALTER TABLE SCHOOL  
MODIFY (SCHOOL_NAME NOT NULL);

ALTER TABLE SCHOOL  
MODIFY (CREATED_BY NOT NULL);

ALTER TABLE SCHOOL  
MODIFY (CREATED_DATE NOT NULL);

ALTER TABLE SCHOOL  
MODIFY (MODIFIED_BY NOT NULL);

ALTER TABLE SCHOOL  
MODIFY (MODIFIED_DATE NOT NULL);

ALTER TABLE SCHOOL
ADD CONSTRAINT SCHOOL_PK PRIMARY KEY 
(
  SCHOOL_ID 
)
ENABLE;

--------------------------------------------------------
--Refefining PKS
--------------------------------------------------------
ALTER TABLE COURSE  
MODIFY (SCHOOL_ID NOT NULL);

ALTER TABLE COURSE
ADD CONSTRAINT COURSE_PK PRIMARY KEY 
(
  COURSE_NO 
, SCHOOL_ID 
)
ENABLE;

ALTER TABLE ENROLLMENT  
MODIFY (SCHOOL_ID NOT NULL);

ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_PK PRIMARY KEY 
(
  SECTION_ID 
, STUDENT_ID 
, SCHOOL_ID 
)
ENABLE;

 

 ALTER TABLE SECTION  
MODIFY (SCHOOL_ID NOT NULL);

ALTER TABLE SECTION
ADD CONSTRAINT SECTION_PK PRIMARY KEY 
(
  SECTION_ID 
, SCHOOL_ID 
)
ENABLE;


 ALTER TABLE STUDENT  
MODIFY (SCHOOL_ID NOT NULL);

ALTER TABLE STUDENT
ADD CONSTRAINT STUDENT_PK PRIMARY KEY 
(
  STUDENT_ID 
, SCHOOL_ID 
)
ENABLE;

--------------------------------------------------------
--Refefining FKS FOR COURSE
--------------------------------------------------------

ALTER TABLE COURSE
ADD CONSTRAINT COURSE_FK1 FOREIGN KEY
(
  PREREQUISITE 
, PREREQUISITE_SCHOOL_ID 
)
REFERENCES COURSE
(
  COURSE_NO 
, SCHOOL_ID 
)
ENABLE;

ALTER TABLE COURSE
ADD CONSTRAINT COURSE_FK2 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;



--------------------------------------------------------
--  Ref Constraints for Table ENROLLMENT
--------------------------------------------------------
ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_FK1 FOREIGN KEY
(
  SECTION_ID 
, SCHOOL_ID 
)
REFERENCES SECTION
(
  SECTION_ID 
, SCHOOL_ID 
)
ENABLE;

ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_FK2 FOREIGN KEY
(
  STUDENT_ID 
, SCHOOL_ID 
)
REFERENCES STUDENT
(
  STUDENT_ID 
, SCHOOL_ID 
)
ENABLE;

ALTER TABLE ENROLLMENT
ADD CONSTRAINT ENROLLMENT_FK3 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;

--------------------------------------------------------
--  Ref Constraints for Table SECTION
--------------------------------------------------------
ALTER TABLE SECTION
ADD CONSTRAINT SECTION_FK1 FOREIGN KEY
(
  COURSE_NO 
, SCHOOL_ID 
)
REFERENCES COURSE
(
  COURSE_NO 
, SCHOOL_ID 
)
ENABLE;

ALTER TABLE SECTION
ADD CONSTRAINT SECTION_FK2 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;

--------------------------------------------------------
--  Ref Constraints for Table STUDENT
--------------------------------------------------------

ALTER TABLE STUDENT
ADD CONSTRAINT STUDENT_FK1 FOREIGN KEY
(
  SCHOOL_ID 
)
REFERENCES SCHOOL
(
  SCHOOL_ID 
)
ENABLE;


--------------------------------------------------------
--  DDL for Trigger TRG02_COURSE
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "TRG02_COURSE" BEFORE
    INSERT OR UPDATE ON COURSE
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/
--------------------------------------------------------
--  DDL for Trigger TRG02_SECTION
--------------------------------------------------------
     
CREATE OR REPLACE TRIGGER "TRG02_SECTION" BEFORE
    INSERT OR UPDATE ON section
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/
--------------------------------------------------------
--  DDL for Trigger TRG02_STUDENT
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "TRG02_STUDENT" BEFORE
    INSERT OR UPDATE ON student
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/


--------------------------------------------------------
--  DDL for Trigger TRG02_ENROLLMENT
--------------------------------------------------------

     
CREATE OR REPLACE TRIGGER "TRG02_ENROLLMENT" BEFORE
    INSERT OR UPDATE ON enrollment
    FOR EACH ROW
BEGIN
    IF inserting THEN
        :new.created_by := user;
        :new.created_date := sysdate;
    END IF;

    :new.modified_by := user;
    :new.modified_date := sysdate;
END;
/
    
