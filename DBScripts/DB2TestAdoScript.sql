CREATE TABLE "TEST_LOGIN"."PERSON"  (
		  "PERSONID" INTEGER NOT NULL , 
		  "FIRSTNAME" VARCHAR(50) NOT NULL , 
		  "LASTNAME" VARCHAR(50) NOT NULL , 
		  "INFO" VARCHAR(50) )   
		 IN "USERSPACE1" ; 


-- DDL Statements for primary key on Table "TEST_LOGIN"."PERSON"

ALTER TABLE "TEST_LOGIN"."PERSON" 
	ADD CONSTRAINT "CC1310181374141" PRIMARY KEY
		("PERSONID");









--------------------------------------------
-- Authorization Statements on Tables/Views 
--------------------------------------------

 

GRANT INSERT ON TABLE "TEST_LOGIN"."PERSON" TO USER "TEST_LOGIN" ;

GRANT SELECT ON TABLE "TEST_LOGIN"."PERSON" TO USER "TEST_LOGIN" ;


CREATE OR REPLACE PROCEDURE TEST_LOGIN.stp_TestInputParameter (in prmPersonID integer)

language SQL
begin
DECLARE SELECT_CURSOR CURSOR WITH RETURN FOR 
	select FirstName,LastName From TEST_LOGIN.Person where PersonID=prmPersonID;

OPEN SELECT_CURSOR;

end
CREATE OR REPLACE PROCEDURE TEST_LOGIN.stp_TestOutputParameter (in prmPersonID integer,OUT prmFullName varchar(101))

language SQL
begin
select FirstName CONCAT ' ' CONCAT LastName into prmFullName
from TEST_LOGIN.Person
where PersonID=prmPersonID;
end
