-- Author:  Christopher Mortimer
-- Date:    2019-10-21
-- Desc:    Import a CSV file to SQL server using the BULK INSERT
-- Note:    Need to change the file to have CRLF not LF (Unix)
--          FIELDQUOTE is not working at the moment
--          Online forums suggest to use SSIS instead of the BULK INSERT method
--          Attempted the SSIS method, and the learning curve was more than cutting code
-- Usage:   Invoke-Sqlcmd -InputFile "nfl-game_type.sql" -ServerInstance "localhost\SQLEXPRESS" | Out-File -FilePath "nfl-game_type.txt"
--          Invoke-Sqlcmd -InputFile "nfl-game_type.sql" -ServerInstance "localhost\SQLEXPRESS" -Username mortimer -Password mortimer | Out-File -FilePath "nfl-game_type.txt" 

SELECT GETDATE() AS TimeOfQuery
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create table
CREATE TABLE [PRD_LA_NFL].[DBO].[GAME_TYPE] (
  GAME_TYPE_ID VARCHAR(50)
    , GAME_TYPE VARCHAR(50)
    , CREATED_DATE VARCHAR(50)
    , CREATE_USER VARCHAR(50)
) ON [PRIMARY]
GO
-- Insert into landing zone from file 
BULK INSERT [PRD_LA_NFL].[DBO].[GAME_TYPE]
FROM N'$(rootPath)\data\game_type.csv'
WITH
(
  FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0A',  
    TABLOCK
)
;
-- Create source image table
CREATE TABLE [PRD_SI_NFL].[DBO].[GAME_TYPE] (
  GAME_TYPE_ID INTEGER NOT NULL
    , GAME_TYPE CHAR(3)
    , CREATED_DATE DATETIMEOFFSET
    , CREATE_USER VARCHAR(50)
    , CONSTRAINT PK_GAME_TYPE_GAME_TYPE_ID PRIMARY KEY CLUSTERED ([GAME_TYPE_ID])
) ON [PRIMARY]
GO
-- Transform from landing into source image with correct data types
INSERT INTO [PRD_SI_NFL].[DBO].[GAME_TYPE]
SELECT  CAST([GAME_TYPE_ID] AS INTEGER)
    , REPLACE([GAME_TYPE] , '"', '')
    , CAST(REPLACE([CREATED_DATE], '"', '') AS DATETIMEOFFSET)
    , REPLACE(REPLACE([CREATE_USER], '"', ''), ',', '')
FROM  [PRD_LA_NFL].[DBO].[GAME_TYPE]
;
SELECT GETDATE() AS TimeOfQuery