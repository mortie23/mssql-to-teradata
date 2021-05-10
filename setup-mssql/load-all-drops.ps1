# Author:   Christopher Mortier
# Date:     2019-10-22
# Desc:     Kick off all the scripts to load the data to SQL Server
# Usage:    From PowerShell in the correct directory
#           .\load-all.ps1

Invoke-Sqlcmd -InputFile "drop-tables.sql" -ServerInstance "localhost\SQLEXPRESS" | Out-File -FilePath "drop-tables.txt"

