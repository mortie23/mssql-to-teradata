-- Author:  Christopher Mortimer
-- Date:    2019-10-21
-- Desc:    Import a CSV file to SQL server using the BULK INSERT
-- Note:    Need to change the file to have CRLF not LF (Unix)
--          FIELDQUOTE is not working at the moment
--          Online forums suggest to use SSIS instead of the BULK INSERT method
--          Attempted the SSIS method, and the learning curve was more than cutting code
-- Usage:   Invoke-Sqlcmd -InputFile "nfl-venue.sql" -ServerInstance "localhost\SQLEXPRESS" | Out-File -FilePath "nfl-venue.txt"
--          Invoke-Sqlcmd -InputFile "nfl-venue.sql" -ServerInstance "localhost\SQLEXPRESS" -Username mortimer -Password mortimer | Out-File -FilePath "nfl-venue.txt" 

SELECT GETDATE() AS TimeOfQuery
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create table
CREATE TABLE [nfl].[VENUE] (
  VENUE_ID VARCHAR(50)
    , VENUE_NAME VARCHAR(50)
    , CAPACITY VARCHAR(50)
    , SURFACE VARCHAR(50)
    , VENUE_TYPE VARCHAR(50)
    , CREATED_DATE VARCHAR(50)
    , CREATE_USER VARCHAR(50)
) ON [PRIMARY]
GO
-- Insert into landing zone from file 
BULK INSERT [nfl].[VENUE]
FROM N'$(rootPath)\data\venue.csv'
WITH
(
  FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0A',  
    TABLOCK
)
;
-- Create source image table
CREATE TABLE [nfl_si].[VENUE] (
  VENUE_ID INTEGER NOT NULL
    , VENUE_NAME VARCHAR(50) NULL
    , CAPACITY INTEGER NULL
    , SURFACE VARCHAR(50) NULL
    , VENUE_TYPE VARCHAR(50) NULL
    , CREATED_DATE DATETIMEOFFSET NULL
    , CREATE_USER VARCHAR(50) NULL
    , CONSTRAINT PK_VENUE_VENUE_ID PRIMARY KEY CLUSTERED ([VENUE_ID])
) ON [PRIMARY]
GO
-- Transform from landing into source image with correct data types
INSERT INTO [nfl_si].[VENUE]
SELECT  CAST([VENUE_ID] AS INTEGER)
    , REPLACE([VENUE_NAME], '"', '')
    , CAST([CAPACITY] AS INTEGER)
    , REPLACE([SURFACE], '"', '')
    , REPLACE([VENUE_TYPE], '"', '')
    , CAST(REPLACE([CREATED_DATE], '"', '') AS DATETIMEOFFSET)
    , REPLACE(REPLACE([CREATE_USER], '"', ''), ',', '')
FROM  [nfl].[VENUE]
;
SELECT GETDATE() AS TimeOfQuery