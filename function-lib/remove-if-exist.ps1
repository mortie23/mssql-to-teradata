# Author:   Christopher Mortimer
# Date:     2020-08-24
# Desc:     Powershell function to remove file after checking if exists
# Usage:    Add this line to your Powershell script to include
#           . .\remove-if-exists.ps1

function remIfExist($FileName) {
  if (Test-Path $FileName) {
    Remove-Item $FileName
    Write-Output (-join('{"message": "info", "deleted": "', $FileName, '"}')) `
      | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  }
}