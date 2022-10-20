--------------------------------------------------------
--  File created - Monday-February-28-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Sequence COURSE_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "COURSE_SEQ"  MINVALUE 1 MAXVALUE 9999999999 INCREMENT BY 1 START WITH 451 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence SECTION_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "SECTION_SEQ"  MINVALUE 1 MAXVALUE 9999999999 INCREMENT BY 1 START WITH 157 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Sequence STUDENT_SEQ
--------------------------------------------------------

   CREATE SEQUENCE  "STUDENT_SEQ"  MINVALUE 1 MAXVALUE 9999999999 INCREMENT BY 1 START WITH 400 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;
--------------------------------------------------------
--  DDL for Trigger TRG01_COURSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "TRG01_COURSE" 
BEFORE INSERT ON COURSE 
FOR EACH ROW 
BEGIN IF inserting 
THEN
    :new.course_no := course_seq.nextval;
    end if;
end;
/
ALTER TRIGGER "TRG01_COURSE" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG01_SECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "TRG01_SECTION" 
BEFORE INSERT ON SECTION 
FOR EACH ROW 
BEGIN IF inserting 
THEN
    :new.section_id := section_seq.nextval;
    end if;
end;
/
ALTER TRIGGER "TRG01_SECTION" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG01_STUDENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "TRG01_STUDENT" BEFORE
    INSERT ON student
    FOR EACH ROW
BEGIN
    IF
        inserting
    THEN
        :new.student_id := student_seq.nextval;
    END IF;
END;
/
ALTER TRIGGER "TRG01_STUDENT" ENABLE;
