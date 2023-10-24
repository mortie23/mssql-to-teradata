-- Author:  Christopher Mortimer
-- Date:    2019-10-21
-- Desc:    Import a CSV file to SQL server using the BULK INSERT
-- Note:    Need to change the file to have CRLF not LF (Unix)
--          FIELDQUOTE is not working at the moment
--          Online forums suggest to use SSIS instead of the BULK INSERT method
--          Attempted the SSIS method, and the learning curve was more than cutting code
-- Usage:   Invoke-Sqlcmd -InputFile "nfl-team_lookup.sql" -ServerInstance "localhost\SQLEXPRESS" | Out-File -FilePath "nfl-team_lookup.txt"
--          Invoke-Sqlcmd -InputFile "nfl-team_lookup.sql" -ServerInstance "localhost\SQLEXPRESS" -Username mortimer -Password mortimer | Out-File -FilePath "nfl-team_lookup.txt" 

SELECT GETDATE() AS TimeOfQuery
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create table
CREATE TABLE [nfl].[TEAM_LOOKUP] (
  TEAM_ID VARCHAR(50)
    , TEAM_LONG VARCHAR(50)
    , TEAM_SHORT VARCHAR(50)
    , CONFERENCE VARCHAR(50)
    , DIVISION VARCHAR(50)
) ON [PRIMARY]
GO
-- Insert into landing zone from file 
BULK INSERT [nfl].[TEAM_LOOKUP]
FROM N'$(rootPath)\data\team_lookup.csv'
WITH
(
  FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0A',  
    TABLOCK
)
;
-- Create source image table
CREATE TABLE [nfl_si].[TEAM_LOOKUP] (
  TEAM_ID INTEGER NOT NULL
    , TEAM_LONG VARCHAR(50)
    , TEAM_SHORT CHAR(3)
    , CONFERENCE CHAR(3)
    , DIVISION VARCHAR(10)
    , CONSTRAINT PK_TEAM_LOOKUP_TEAM_ID PRIMARY KEY CLUSTERED ([TEAM_ID])
) ON [PRIMARY]
GO
-- Transform from landing into source image with correct data types
INSERT INTO [nfl_si].[TEAM_LOOKUP]
SELECT  CAST([TEAM_ID] AS INTEGER)
        , REPLACE([TEAM_LONG], '"', '')
    , REPLACE([TEAM_SHORT], '"', '')
    , REPLACE([CONFERENCE], '"', '')
    , REPLACE(REPLACE([DIVISION], '"', ''), ',', '')
FROM  [nfl].[TEAM_LOOKUP]
;
SELECT GETDATE() AS TimeOfQuery