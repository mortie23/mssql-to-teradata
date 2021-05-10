# Author: Christopher Mortimer
# Date:   2020-08-25
# Desc:   Powershell script to run an SQL file
# Usage:  Add this line to your Powershell script to include
#         . .\function-lib\sql.ps1

$timestampLocal = $(Get-TimeStamp) 
function sql($rootPath, $sqlFile) {
  <#
  .sql
  sql function executes an SQL file against a SQL server instance
  
  param
  $rootPath: The root path of the calling script
  $sqlFile: The name of the sql file
  #>
  Write-Output (-join('{"function" : "', ("{0}" -f $MyInvocation.MyCommand), '", "timestamp": "', $timestampLocal,'"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "sqlfile": "', $sqlfile, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  # Run the extracts
  # Need to set the Querytimeout to 0 (infinite)
  Invoke-Sqlcmd -InputFile "$sqlFile.sql" -ServerInstance "$SQLServer" -Database "$SQLDBName" -Querytimeout 0 | `
    Out-File -FilePath "$rootPath\logs\run_mssql_$timestamp.json" -Append
}
