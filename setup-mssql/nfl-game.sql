-- Author:  Christopher Mortimer
-- Date:    2019-10-21
-- Desc:    Import a CSV file to SQL server using the BULK INSERT
-- Note:    Need to change the file to have CRLF not LF (Unix)
--          FIELDQUOTE is not working at the moment
--          Online forums suggest to use SSIS instead of the BULK INSERT method
--          Attempted the SSIS method, and the learning curve was more than cutting code
-- Usage:   Invoke-Sqlcmd -InputFile "nfl-game.sql" -ServerInstance "localhost\SQLEXPRESS" | Out-File -FilePath "nfl-game.txt"
--          Invoke-Sqlcmd -InputFile "nfl-game.sql" -ServerInstance "localhost\SQLEXPRESS" -Username mortimer -Password mortimer | Out-File -FilePath "nfl-game.txt" 

SELECT GETDATE() AS TimeOfQuery
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create table
CREATE TABLE [PRD_LA_NFL].[DBO].[GAME] (
  [GAME_ID] VARCHAR(50) NULL
  , [GAME_TYPE_ID] VARCHAR(50) NULL
  , [WEEK] VARCHAR(50) NULL
  , [TEAM_SHORT] VARCHAR(50) NULL
  , [OPPONENT] VARCHAR(50) NULL
  , [CREATED_DATE] VARCHAR(50) NULL
  , [CREATE_USER] VARCHAR(50) NULL
) ON [PRIMARY]
GO
-- Insert into landing zone from file 
BULK INSERT [PRD_LA_NFL].[DBO].[GAME]
FROM N'$(rootPath)\data\game.csv'
WITH
(
  FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0A',  
    TABLOCK
)
;
-- Create source image table
CREATE TABLE [PRD_SI_NFL].[DBO].[GAME] (
  [GAME_ID] INTEGER NOT NULL
  , [GAME_TYPE_ID] INTEGER NOT NULL
  , [WEEK] INTEGER NULL
  , [TEAM_SHORT] [CHAR](3) NOT NULL
  , [OPPONENT] [VARCHAR](50) NULL
  , [CREATED_DATE] DATETIMEOFFSET NULL
  , [CREATE_USER] [VARCHAR](50) NULL
  , CONSTRAINT PK_GAME_GAME_ID PRIMARY KEY CLUSTERED ([GAME_ID])
  , CONSTRAINT FK_GAME_GAME_TYPE_ID FOREIGN KEY ([GAME_TYPE_ID])
    REFERENCES [dbo].[GAME_TYPE] ([GAME_TYPE_ID])
) ON [PRIMARY]
GO
-- Transform from landing into source image with correct data types
INSERT INTO [PRD_SI_NFL].[DBO].[GAME]
SELECT  CAST([GAME_ID] AS INTEGER)
    , CAST([GAME_TYPE_ID] AS INTEGER)
    , CAST([WEEK] AS INTEGER)
    , REPLACE([TEAM_SHORT], '"', '')
    , REPLACE([OPPONENT], '"', '')
    , CAST(REPLACE([CREATED_DATE], '"', '') AS datetimeoffset)
    , REPLACE(REPLACE([CREATE_USER], '"', ''), ',', '')
FROM  [PRD_LA_NFL].[DBO].[GAME]
;
SELECT GETDATE() AS TimeOfQuery