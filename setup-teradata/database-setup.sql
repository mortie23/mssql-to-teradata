-- Deploy on a brand new system for use

-- 1. Sanity Check on new system
-- First a bit of maths
-- check the total perm space in the system then give 
-- sysdba about 60%, 
-- spool reserve about 30% 
-- leave DBC with 10%

SELECT DatabaseName
      , SUM(MAXPERM)
      , SUM(CURRENTPERM)
FROM DBC.Diskspace
group by 1
;

SELECT CAST('SYSDBA' AS VARCHAR(100)) AS USR
      , FLOOR(SUM(MaxPerm)*0.6/100000000)*100000000 AS PERMS
FROM DBC.Diskspace 
WHERE DatabaseName='DBC'
UNION ALL
SELECT CAST('SPOOL_RESERVE' AS VARCHAR(100)) AS USR
      , FLOOR(SUM(MaxPerm)*0.3/100000000)*100000000 AS PERMS
FROM DBC.Diskspace
WHERE DatabaseName='DBC'
UNION ALL
SELECT CAST('SYS_USERS' AS VARCHAR(100)) AS USR
      , SUM(MaxPerm)*0 AS PERMS
FROM DBC.Diskspace
WHERE DatabaseName='DBC'
UNION ALL
SELECT CAST('SECADMIN' AS VARCHAR(100)) AS USR
      , FLOOR(SUM(MaxPerm)*0.02/100000000)*100000000 AS PERMS
FROM DBC.Diskspace
WHERE DatabaseName='DBC'
;
/*
 USR           PERMS          
 ------------- -------------- 
 SYS_USERS                  0
 SECADMIN         500,000,000
 SPOOL_RESERVE  7,700,000,000
 SYSDBA        15,400,000,000
*/

--Logon As DBC and run following Script
CREATE USER SYSDBA FROM DBC AS 
  PASSWORD = SYSDBA
  PERM = 15E9 
  NO Fallback 
  NO Before Journal NO After Journal 
;
COMMENT ON SYSDBA AS 'Database Administrator' ;
GRANT ALL ON SYSDBA TO SYSDBA WITH GRANT OPTION ;
GRANT SELECT ON DBC TO SYSDBA  WITH GRANT OPTION;
GRANT SELECT ON Sys_Calendar TO SYSDBA WITH GRANT OPTION;

-- Logon AS DBC and run following Script
CREATE DATABASE SPOOL_RESERVE FROM DBC AS 
  PERM = 7E9 
  NO Fallback 
  NO Before Journal NO After Journal 
;
COMMENT ON SPOOL_RESERVE AS 'Spool Reserve';

------------------------------------------
-- Security Administrator
CREATE USER SECADMIN FROM DBC AS PASSWORD = ******** 
  PERM = 500E6 
  NO Fallback 
  NO Before Journal NO After Journal 
;
COMMENT ON SECADMIN AS 'Security Administrator.' ;
GRANT USER ON SECADMIN TO SECADMIN; 
GRANT ROLE TO SECADMIN ;
GRANT PROFILE TO SECADMIN  ; 
GRANT SELECT ON DBC TO SECADMIN  ;
GRANT UPDATE ON DBC.SysSecDefaults TO SECADMIN  ;
GRANT EXECUTE ON DBC.LogonRule TO SECADMIN ;
GRANT EXECUTE ON DBC.AccLogRule TO SECADMIN ;
GRANT DELETE ON DBC.AccLogTbl TO SECADMIN  ;
GRANT DELETE ON DBC.DeleteAccessLog TO SECADMIN  ;
GRANT DELETE ON DBC.EventLog TO SECADMIN  ;

--Next, provide the security administrator the authority to control and monitor user logons, 
--using the GRANT/REVOKE LOGON and BEGIN/END LOGGING statements, as follows:
--Log off Teradata Database as user DBC
--Log back onto Teradata Database as username SECADMIN. 
--Enter the following Teradata SQL statement to initiate an audit trail on the execution of 
--any BEGIN/END LOGGING or GRANT/REVOKE LOGON statement: 
BEGIN LOGGING WITH TEXT ON EACH ALL ON MACRO DBC.LogonRule, MACRO DBC.AccLogRule ;

--Logon as SYSDBA and run rollowing Script to create User Database
CREATE DATABASE SYS_USERS FROM SYSDBA AS 
  PERM = 0 
  NO Fallback 
  NO Before Journal NO After Journal 
;
COMMENT ON SYS_USERS AS 'System User Database' ;
GRANT ALL ON SYS_USERS TO SYSDBA;

--Logon as SYSDBA and run following Script to create the Production Environment DBA
CREATE USER PRDDBA FROM SYSDBA AS 
  PASSWORD = PRDDBA 
  PERM =  0
  NO Fallback 
  NO Before Journal NO After Journal 
;
COMMENT ON PRDDBA AS 'Production DBA' ;
GRANT ALL ON PRDDBA TO PRDDBA WITH GRANT OPTION ;
GRANT SELECT ON DBC TO PRDDBA WITH GRANT OPTION;
GRANT SELECT ON Sys_Calendar TO PRDDBA WITH GRANT OPTION;
GRANT ALL ON SYS_USERS TO PRDDBA WITH GRANT OPTION;
--Logon as SYSDBA and run rollowing Script to create the Development Environment DBA
CREATE USER DEVDBA FROM SysDBA AS 
  PASSWORD = DEVDBA
  PERM =  0
  NO Fallback 
  NO Before Journal NO After Journal
;
COMMENT ON DEVDBA AS 'Development DBA' ;
GRANT ALL ON DEVDBA TO DEVDBA WITH GRANT OPTION ;
GRANT SELECT ON DBC TO DEVDBA WITH GRANT OPTION;
GRANT SELECT ON Sys_Calendar TO DEVDBA WITH GRANT OPTION;
GRANT ALL ON SYS_USERS TO DEVDBA WITH GRANT OPTION;

--Logon as PRDDBA and run rollowing Script to create Production users database 
CREATE DATABASE PRD_USERS FROM PRDDBA AS
   PERM = 0
   NO FALLBACK
   NO BEFORE JOURNAL
   NO AFTER JOURNAL
;

-- Storage Heirachy
-- Analytical Data Store
CREATE DATABASE PRD_ADS FROM PRDDBA AS 
  PERM = 0 
  NO Fallback 
  NO Before Journal NO After Journal 
;
COMMENT ON PRD_ADS AS 'Production Analytical Data Store' ;
GRANT ALL ON PRD_ADS TO PRDDBA WITH GRANT OPTION ;
-- Business Area NFL
CREATE DATABASE PRD_ADS_NFL_DB FROM PRD_ADS AS
   PERM = 0
   NO FALLBACK
   NO BEFORE JOURNAL
   NO AFTER JOURNAL
;
COMMENT ON PRD_ADS AS 'NFL ADS' ;
GRANT ALL ON PRD_ADS TO PRDDBA WITH GRANT OPTION ;

-- Give Space
-- ADS
-- Logon as SYSDBA for this
CREATE DATABASE GS_TEMP FROM SYSDBA AS 
PERM = 10E9
;
GIVE GS_TEMP TO PRDDBA
;
DROP DATABASE GS_TEMP 
;
-- Logon as PRDDBA for this
CREATE DATABASE GS_TEMP FROM PRDDBA AS 
PERM = 10E9
;
GIVE GS_TEMP TO PRD_ADS
;
DROP DATABASE GS_TEMP 
;
-- NFL
CREATE DATABASE GS_TEMP FROM PRD_ADS AS 
PERM = 10E9
;
GIVE GS_TEMP TO PRD_ADS_NFL_DB
;
DROP DATABASE GS_TEMP 
;

------------------------------------------------------
-- Users
-- Logon as PRDDBA
CREATE USER JERRYRICE FROM PRD_USERS AS
  PASSWORD = JERRYRICE 
  PERM = 0 
  NO Fallback 
  NO Before Journal NO After Journal
  DEFAULT ROLE = ALL
;

------------------------------------------
-- Roles
-- Log on as SECADMIN
CREATE ROLE R_NFL_PRD;
GRANT R_NFL_PRD TO JERRYRICE;
-- Log on as PRDDBA
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE TABLE, DROP TABLE ON PRD_ADS_NFL_DB TO R_NFL_PRD ;
GRANT SELECT, CREATE VIEW, DROP VIEW ON PRD_ADS_NFL_DB TO R_NFL_PRD ;
