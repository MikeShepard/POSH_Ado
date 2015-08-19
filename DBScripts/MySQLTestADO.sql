delimiter $$

CREATE TABLE person (
  PersonID int(11) NOT NULL AUTO_INCREMENT,
  FirstName varchar(50) NOT NULL,
  LastName varchar(50) NOT NULL,
  Info varchar(50) DEFAULT NULL,
  PRIMARY KEY (PersonID)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8$$

DELIMITER $$

CREATE DEFINER=root@localhost PROCEDURE stp_TestInputParameter( prmPersonID int)
BEGIN
  select * from Person where PersonID=prmPersonID;
END

DELIMITER $$

CREATE DEFINER=root@localhost PROCEDURE stp_TestOutputParameter(IN prmPersonID int,OUT prmFullName varchar(101))
BEGIN
select Concat(FirstName, ' ' , LastName) into prmFullName from Person
where PersonID=prmPersonID;
END


INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('1', 'Chad', 'Miller', 'Project Owner');
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('2', 'Brend', 'Kriszio', NULL);
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('3', 'Mike', 'Shepard', 'AdoLib');
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('4', 'Max', 'Trinidad', NULL);
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('5', 'Steve', 'Murawski', NULL);