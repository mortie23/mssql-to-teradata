# Author:   Christopher Mortimer
# Date:     2020-08-24
# Desc:     Powershell function to expand archive to files
# Usage:    Add this line to your Powershell script to include
#           . .\function-lib\expand.ps1

. .\function-lib\remove-if-exist.ps1

$timestampLocal = $(Get-TimeStamp) 
# Expand the files
function exp ($rootPath, $archiveFile, $targetDirectory) {
  Write-Output (-join('{"function" : "', ("{0}" -f $MyInvocation.MyCommand), '", "timestamp": "', $timestampLocal,'"}')) `
    |Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "archiveFile": "', $archiveFile, '"}')) `
    |Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "targetDirectory": "', $targetDirectory, '"}')) `
    |Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
    
  # Clean up extract CSV if there
  remIfExist "$rootPath\extract\tablename.csv"
  
  Add-Type -Assembly System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory("$archiveFile", "$targetDirectory")
  # Optional to remove archive after uncompress
  #Remove-Item "$archiveFile"
  Write-Output (-join('{"message": "info", "expanded": "', $archiveFile, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
}