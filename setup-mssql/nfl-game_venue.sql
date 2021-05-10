-- Author:  Christopher Mortimer
-- Date:    2019-10-21
-- Desc:    Import a CSV file to SQL server using the BULK INSERT
-- Note:    Need to change the file to have CRLF not LF (Unix)
--          FIELDQUOTE is not working at the moment
--          Online forums suggest to use SSIS instead of the BULK INSERT method
--          Attempted the SSIS method, and the learning curve was more than cutting code
-- Usage:   Invoke-Sqlcmd -InputFile "nfl-game_venue.sql" -ServerInstance "localhost\SQLEXPRESS" | Out-File -FilePath "nfl-game_venue.txt"
--          Invoke-Sqlcmd -InputFile "nfl-game_venue.sql" -ServerInstance "localhost\SQLEXPRESS" -Username mortimer -Password mortimer | Out-File -FilePath "nfl-game_venue.txt" 

SELECT GETDATE() AS TimeOfQuery
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create table
CREATE TABLE [PRD_LA_NFL].[DBO].[GAME_VENUE] (
  [GAME_ID] VARCHAR(50) NULL
    , [VENUE_ID] VARCHAR(50) NULL
    , [CREATED_DATE] VARCHAR(50) NULL
    , [CREATE_USER] VARCHAR(50) NULL
) ON [PRIMARY]
GO
-- Insert into landing zone from file 
BULK INSERT [PRD_LA_NFL].[DBO].[GAME_VENUE]
FROM N'$(rootPath)\data\game_venue.csv'
WITH
(
  FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0A',  
    TABLOCK
)
;
-- Create source image table
CREATE TABLE [PRD_SI_NFL].[DBO].[GAME_VENUE] (
  [GAME_ID] INTEGER NULL
    , [VENUE_ID] INTEGER NULL
    , [CREATED_DATE] DATETIMEOFFSET NULL
    , [CREATE_USER] VARCHAR(50) NULL
    , CONSTRAINT FK_GAME_VENUE_GAME_ID FOREIGN KEY ([GAME_ID])
    REFERENCES [dbo].[GAME] ([GAME_ID])
    , CONSTRAINT FK_GAME_VENUE_VENUE_ID FOREIGN KEY ([VENUE_ID])
    REFERENCES [dbo].[VENUE] ([VENUE_ID])
) ON [PRIMARY]
GO
-- Transform from landing into source image with correct data types
INSERT INTO [PRD_SI_NFL].[DBO].[GAME_VENUE]
SELECT  CAST([GAME_ID] AS INTEGER)
    , CAST([VENUE_ID] AS INTEGER)
    , CAST(REPLACE([CREATED_DATE], '"', '') AS DATETIMEOFFSET)
    , REPLACE(REPLACE([CREATE_USER], '"', ''), ',', '')
FROM  [PRD_LA_NFL].[DBO].[GAME_VENUE]
;
SELECT GETDATE() AS TimeOfQuery