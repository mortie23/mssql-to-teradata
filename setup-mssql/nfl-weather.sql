-- Author:  Christopher Mortimer
-- Date:    2019-10-21
-- Desc:    Import a CSV file to SQL server using the BULK INSERT
-- Note:    Need to change the file to have CRLF not LF (Unix)
--          FIELDQUOTE is not working at the moment
--          Online forums suggest to use SSIS instead of the BULK INSERT method
--          Attempted the SSIS method, and the learning curve was more than cutting code
-- Usage:   Invoke-Sqlcmd -InputFile "nfl-weather.sql" -ServerInstance "localhost\SQLEXPRESS" | Out-File -FilePath "nfl-weather.txt"
--          Invoke-Sqlcmd -InputFile "nfl-weather.sql" -ServerInstance "localhost\SQLEXPRESS" -Username mortimer -Password mortimer | Out-File -FilePath "nfl-weather.txt" 

SELECT GETDATE() AS TimeOfQuery
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create table
CREATE TABLE [PRD_LA_NFL].[DBO].[WEATHER] (
  [GAME_ID] VARCHAR(50)
    , [TEMPERATURE] VARCHAR(50)
    , [WEATHER_CONDITION] VARCHAR(50)
    , [WIND_SPEED] VARCHAR(50)
    , [HUMIDITY] VARCHAR(50)
    , [WIND_DIRECTION] VARCHAR(50)
    , [CREATED_DATE] VARCHAR(50)
    , [CREATE_USER] VARCHAR(50)
) ON [PRIMARY]
GO
-- Insert into landing zone from file 
BULK INSERT [PRD_LA_NFL].[DBO].[WEATHER]
FROM N'$(rootPath)\data\weather.csv'
WITH
(
  FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0A',  
    TABLOCK
)
;
-- Create source image table
CREATE TABLE [PRD_SI_NFL].[DBO].[WEATHER] (
  [GAME_ID] INTEGER NOT NULL
    , [TEMPERATURE] INTEGER NULL
    , [WEATHER_CONDITION] VARCHAR(50) NULL
    , [WIND_SPEED] INTEGER NULL
    , [HUMIDITY] INTEGER NULL
    , [WIND_DIRECTION] CHAR(3) NULL
    , [CREATED_DATE] DATETIMEOFFSET NULL
    , [CREATE_USER] VARCHAR(50) NULL
    , CONSTRAINT FK_WEATHER_GAME_ID FOREIGN KEY ([GAME_ID])
    REFERENCES [dbo].[GAME] ([GAME_ID])
) ON [PRIMARY]
GO
-- Transform from landing into source image with correct data types
INSERT INTO [PRD_SI_NFL].[DBO].[WEATHER]
SELECT  CAST([GAME_ID] AS INTEGER)
    , CAST([TEMPERATURE] AS INTEGER)
    , REPLACE([WEATHER_CONDITION], '"', '')
    , CAST([WIND_SPEED] AS INTEGER)
    , CAST([HUMIDITY] AS INTEGER)
    , REPLACE([WIND_DIRECTION], '"', '')
    , CAST(REPLACE([CREATED_DATE], '"', '') AS DATETIMEOFFSET)
    , REPLACE(REPLACE([CREATE_USER], '"', ''), ',', '')
FROM  [PRD_LA_NFL].[DBO].[WEATHER]
;
SELECT GETDATE() AS TimeOfQuery