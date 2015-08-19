/********************* ROLES **********************/

CREATE ROLE RDB$ADMIN;
/********************* UDFS ***********************/

/****************** GENERATORS ********************/

/******************** DOMAINS *********************/

/******************* PROCEDURES ******************/

SET TERM ^ ;
ALTER PROCEDURE STP_TESTINPUTPARAMETER (
    PRMPERSONID Integer )
RETURNS (
    PERSONID Integer,
    FIRSTNAME Varchar(50),
    LASTNAME Varchar(50),
    INFO Varchar(50) )
AS
BEGIN
	FOR SELECT a.PersonID, a.FirstName, a.LastName, a.Info
	    FROM Person a
	    where a.PersonID=:prmPersonID
	    INTO :PersonID, :FirstName, :LastName, :Info
	DO
	BEGIN
		SUSPEND;
	END
END^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE STP_TESTINPUTPARAMETER TO  SYSDBA;

GRANT EXECUTE
 ON PROCEDURE STP_TESTINPUTPARAMETER TO  TEST_LOGIN;




SET TERM ^ ;
ALTER PROCEDURE STP_TESTOUTPUTPARAMETER (
    PRMPERSONID Integer )
RETURNS (
    PRMFULLNAME Varchar(101) )
AS
BEGIN
  select a.FIRSTNAME || ' ' || a.LASTNAME
  from Person a
  where a.PERSONID = :prmPersonID
  into :prmFullName;
  suspend;
END^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE STP_TESTOUTPUTPARAMETER TO  SYSDBA;

GRANT EXECUTE
 ON PROCEDURE STP_TESTOUTPUTPARAMETER TO  TEST_LOGIN;



/******************** TABLES **********************/

CREATE TABLE PERSON
(
  PERSONID Integer NOT NULL,
  FIRSTNAME Varchar(50) NOT NULL,
  LASTNAME Varchar(50) NOT NULL,
  INFO Varchar(50),
  PRIMARY KEY (PERSONID)
);
/********************* VIEWS **********************/

/******************* EXCEPTIONS *******************/

/******************** TRIGGERS ********************/


SET TERM ^ ;
ALTER PROCEDURE STP_TESTINPUTPARAMETER (
    PRMPERSONID Integer )
RETURNS (
    PERSONID Integer,
    FIRSTNAME Varchar(50),
    LASTNAME Varchar(50),
    INFO Varchar(50) )
AS
BEGIN
	FOR SELECT a.PersonID, a.FirstName, a.LastName, a.Info
	    FROM Person a
	    where a.PersonID=:prmPersonID
	    INTO :PersonID, :FirstName, :LastName, :Info
	DO
	BEGIN
		SUSPEND;
	END
END^
SET TERM ; ^


SET TERM ^ ;
ALTER PROCEDURE STP_TESTOUTPUTPARAMETER (
    PRMPERSONID Integer )
RETURNS (
    PRMFULLNAME Varchar(101) )
AS
BEGIN
  select a.FIRSTNAME || ' ' || a.LASTNAME
  from Person a
  where a.PERSONID = :prmPersonID
  into :prmFullName;
  suspend;
END^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE STP_TESTINPUTPARAMETER TO  SYSDBA;

GRANT EXECUTE
 ON PROCEDURE STP_TESTINPUTPARAMETER TO  TEST_LOGIN;


GRANT EXECUTE
 ON PROCEDURE STP_TESTOUTPUTPARAMETER TO  TEST_LOGIN;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON PERSON TO  SYSDBA WITH GRANT OPTION;

GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON PERSON TO  TEST_LOGIN;





INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('1', 'Chad', 'Miller', 'Project Owner');
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('2', 'Brend', 'Kriszio', NULL);
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('3', 'Mike', 'Shepard', 'AdoLib');
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('4', 'Max', 'Trinidad', NULL);
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('5', 'Steve', 'Murawski', NULL);
