-- Author:  Christopher Mortimer
-- Date:    2019-10-24
-- Desc:    Drop contraints and then tables

USE [PRD_SI_NFL]
GO
SELECT GETDATE() AS LogTimestamp, 'Start of drop contraint' AS LogMessage
-- Drop all the constraints first
DECLARE @SQL varchar(4000)=''
SELECT @SQL = 
        @SQL + 'ALTER TABLE ' + s.name+'.'+t.name + ' DROP CONSTRAINT [' + RTRIM(f.name) +'];' + CHAR(13)
FROM sys.Tables t
    INNER JOIN sys.foreign_keys f
    ON  f.parent_object_id = t.object_id
    INNER JOIN sys.schemas s
    ON  s.schema_id = f.schema_id
-- Log Time
SELECT GETDATE() AS LogTimestamp, 'Drop Contraints statement built' AS LogMessage
PRINT @SQL
EXEC (@SQL)

-- GAME_STATS
SELECT GETDATE() AS LogTimestamp, 'Drop GAME_STATS' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[GAME_STATS]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[GAME_STATS]
-- GAME_TYPE
SELECT GETDATE() AS LogTimestamp, 'Drop GAME_TYPE' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[GAME_TYPE]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[GAME_TYPE]
-- GAME_VENUE
SELECT GETDATE() AS LogTimestamp, 'Drop GAME_VENUE' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[GAME_VENUE]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[GAME_VENUE]
-- GAME
SELECT GETDATE() AS LogTimestamp, 'Drop GAME' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[GAME]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[GAME]
-- PLAYER
SELECT GETDATE() AS LogTimestamp, 'Drop PLAYER' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[PLAYER]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[PLAYER]
-- TEAM_LOOKUP
SELECT GETDATE() AS LogTimestamp, 'Drop TEAM_LOOKUP' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[TEAM_LOOKUP]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[TEAM_LOOKUP]
-- VENUE
SELECT GETDATE() AS LogTimestamp, 'Drop VENUE' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[VENUE]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[VENUE]
-- WEATHER
SELECT GETDATE() AS LogTimestamp, 'Drop WEATHER' AS LogMessage
DROP TABLE IF EXISTS [PRD_LA_NFL].[DBO].[WEATHER]
DROP TABLE IF EXISTS [PRD_SI_NFL].[DBO].[WEATHER]

SELECT GETDATE() AS LogTimestamp, 'Completed drops' AS LogMessage
