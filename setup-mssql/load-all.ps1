# Author:   Christopher Mortier
# Date:     2019-10-22
# Date:     2021-05-03
# Desc:     Kick off all the scripts to load the data to SQL Server
# Usage:    From PowerShell in the correct directory
#           .\load-all.ps1 <serverName>
# Param:   
# @serverName: XPSCOLD

$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Pass the server name as an argument
$serverName = $args[0]
Write-Host $serverName

function drops($rootPath) {
  <#
  .drops
  drops function executes the sql to drop all constraints and then tables
  #>
  Invoke-Sqlcmd -InputFile "$rootPath\drop-tables.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\drop-tables.txt"
  Write-Host "Dropped"
}
# Drop all constrainsts and tables
drops $rootPath

# Load all the data
function loads($rootPath) {
  <#
  .loads
  loads function executes the sql for each table to load the CSV files to the tables
  #>
  # No Dependancies
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-team_lookup.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-team_lookup.txt"
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game_type.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-game_type.txt"
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-venue.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-venue.txt"
  # Dependancies GAME_TYPE
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-game.txt"
  # Dependancies GAME and TEAM_LOOKUP
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game_stats.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-game_stats.txt"
  # Dependancies GAME and VENUE
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game_venue.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-game_venue.txt"
  # Dependancies GAME
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-weather.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-weather.txt"
  # Dependancies GAME and TEAM_LOOKUP
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-player.sql" -ServerInstance "$serverName" -Variable "rootPath=$rootPath" | Out-File -FilePath "$rootPath\nfl-player.txt"
  Write-Host "Loaded"
}
# Load all tables
loads $rootPath