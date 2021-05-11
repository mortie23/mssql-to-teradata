# Author:   Christopher Mortimer
# Date:     2020-08-24
# Desc:     Powershell script to run all extracts and then export to CSV
# Usage:    From PowerShell in the correct directory
#           .\run-ride-extracts.ps1 

$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. .\function-lib\timestamp.ps1
$timestamp = $(Get-TimeStamp) 
# Include functions from the functoin library directory
. .\function-lib\sql.ps1
. .\function-lib\csv.ps1
. .\function-lib\getdef.ps1
. .\function-lib\compress.ps1
. .\function-lib\scp.ps1

Write-Output (-join('{"message": "start-run", "rootPath": "', $rootPath, '", "timestamp": "', $timestamp,'", "user": "', $env:UserName,'"}')) `
  | Tee-Object -file "$rootPath\logs\run_ride_$timestamp.json" -Append

# Function to get variables from env file 
Get-Content env.ini | Foreach-Object{
  $var = $_.Split('=')
  New-Variable -Name $var[0] -Value $var[1]
}
Write-Output (-join('{"message": "env", "SQLServer": "', $SQLServer, '", "SQLDBName": "', $SQLDBName , '"}')) `
  | Tee-Object -file "$rootPath\logs\run_ride_$timestamp.json" -Append

# Run functions 
# Export to CSVs the table and definitions
function Extract-CSV($rootPath, $tableName) {
  csv "$rootPath" "$tableName"
  getDef "$rootPath" "$tableName"
}
Extract-CSV $rootPath "GAME_STATS"
Extract-CSV $rootPath "GAME_TYPE"
Extract-CSV $rootPath "GAME_VENUE"
Extract-CSV $rootPath "GAME"
Extract-CSV $rootPath "PLAYER"
Extract-CSV $rootPath "TEAM_LOOKUP"
Extract-CSV $rootPath "VENUE"
Extract-CSV $rootPath "WEATHER"

# Finish off
Set-Location -Path "$rootPath"
Write-Output (-join('{"message": "end-run", "timestamp": "', $timestamp,'"}')) `
  | Tee-Object -file "$rootPath\logs\run_ride_$timestamp.json" -Append
