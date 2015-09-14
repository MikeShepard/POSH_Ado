CREATE TABLE [dbo].[Person](
	[PersonID] [int] NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[Info] [varchar](50) NULL
) ON [PRIMARY]

go

INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('1', 'Chad', 'Miller', 'Project Owner');
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('2', 'Brend', 'Kriszio', NULL);
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('3', 'Mike', 'Shepard', 'AdoLib');
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('4', 'Max', 'Trinidad', NULL);
INSERT INTO PERSON (PERSONID, FIRSTNAME, LASTNAME, INFO) VALUES ('5', 'Steve', 'Murawski', NULL);

go
USE [TestADONET]
GO

/****** Object:  StoredProcedure [dbo].[stp_TestInputParameter]    Script Date: 07/30/2011 16:28:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[stp_TestInputParameter]
@PersonID int
as
select * from Person
where PersonID=@PersonID
GO

/****** Object:  StoredProcedure [dbo].[stp_TestOutputParameter]    Script Date: 07/30/2011 16:28:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[stp_TestOutputParameter]
@PersonID int,
@FullName varchar(101) OUTPUT
as
select @FullName=FirstName+' '+LastName from Person
where PersonID=@PersonID

GO

