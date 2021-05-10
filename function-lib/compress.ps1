# Author:   Christopher Mortimer
# Date:     2020-08-24
# Desc:     Powershell function to compress files in a directory
# Usage:    Add this line to your Powershell script to include
#           . .\function-lib\compress.ps1

. .\function-lib\remove-if-exist.ps1

$timestampLocal = $(Get-TimeStamp) 
# Compress the files
function compress($rootPath, $archiveFile, $sourceDirectory) {
  Write-Output (-join('{"function" : "', ("{0}" -f $MyInvocation.MyCommand), '", "timestamp": "', $timestampLocal,'"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "archiveFile": "', $archiveFile, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "sourceDirectory": "', $sourceDirectory, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  
  remIfExist "$archiveFile"
  Write-Output (-join('{"message": "info", "deleted": "', $archiveFile, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  Add-Type -Assembly System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory("$sourceDirectory", `
      "$archiveFile")
  Write-Output (-join('{"message": "info", "compressed": "', $archiveFile, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
}