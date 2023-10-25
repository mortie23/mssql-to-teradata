CREATE LOGIN <userid> WITH PASSWORD = '<>'
GO
CREATE USER <userid> FOR LOGIN <userid>   
;
USE mortimer_dev
GO
GRANT SELECT ON DATABASE::mortimer_dev TO <userid>
;
