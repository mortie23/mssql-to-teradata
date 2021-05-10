# Author:   Christopher Mortier
# Date:     2019-10-22
# Date:     2021-05-03
# Desc:     Kick off all the scripts to load the data to SQL Server
# Usage:    From PowerShell in the correct directory
#           .\load-all.ps1 <serverName>
# Param:   
# @serverName: XPSCOLD

$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host $rootPath
. .\function-lib\timestamp.ps1
$timestamp = $(Get-TimeStamp) 
Write-Host $timestamp

# Pass the server name as an argument
$serverName = $args[0]
Write-Host $serverName

function drops {
  <#
  .drops
  drops function executes the sql to drop all constraints and then tables
  #>
  Invoke-Sqlcmd -InputFile "$rootPath\drop-tables.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\drop-tables.txt"
}
# Drop all constrainsts and tables
drops

# Load all the data
function loads {
  <#
  .loads
  loads function executes the sql for each table to load the CSV files to the tables
  #>
  # No Dependancies
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-team_lookup.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-team_lookup.txt"
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game_type.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-game_type.txt"
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-venue.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-venue.txt"
  # Dependancies GAME_TYPE
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-game.txt"
  # Dependancies GAME and TEAM_LOOKUP
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game_stats.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-game_stats.txt"
  # Dependancies GAME and VENUE
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-game_venue.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-game_venue.txt"
  # Dependancies GAME
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-weather.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-weather.txt"
  # Dependancies GAME and TEAM_LOOKUP
  Invoke-Sqlcmd -InputFile "$rootPath\nfl-player.sql" -ServerInstance "$serverName" | Out-File -FilePath "$rootPath\nfl-player.txt"
}
# Load all tables
loads