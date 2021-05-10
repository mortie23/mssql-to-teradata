# Author: Christopher Mortimer
# Date:   2020-08-24
# Desc:   Powershell function to export a SQL Server table to a CSV file.
# Usage:  Add this line to your Powershell script to include
#         . .\function-lib\csv.ps1

$timestampLocal = $(Get-TimeStamp) 
# SQL Query
function csv($rootPath, $tableName) {
  <#
  .csv
  csv function exports a table to CSV
  #>
  Write-Output (-join('{"function" : "', ("{0}" -f $MyInvocation.MyCommand), '", "timestamp": "', $timestampLocal,'"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "tableName": "', $tableName, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append

  $SqlQuery = "SELECT * FROM [$database].[$schema].[$tableName]" 

  $SqlConnection = New-Object System.Data.SqlClient.SqlConnection  
  $SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True;"  
  $SqlCmd = New-Object System.Data.SqlClient.SqlCommand  
  $SqlCmd.CommandText = $SqlQuery  
  $SqlCmd.Connection = $SqlConnection  
  $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter  
  $SqlAdapter.SelectCommand = $SqlCmd   

  # Set the date format
  (Get-Culture).DateTimeFormat.ShortDatePattern="yyyy-MM-dd"
  # Export the data to file  
  $DataSet = New-Object System.Data.DataSet  
  $SqlAdapter.Fill($DataSet)  
  Write-Output (-join('{"message": "info", "writing-csv": "', $tableName, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  # This method adds headers which Teradata tdload does not like
  # Not using tdload anymore for reasons, using full TPT now
  $DataSet.Tables[0] | export-csv -Delimiter ',' -Path "$rootPath\extract\$tableName.csv" -NoTypeInformation
  #$DataSet.Tables[0] | ConvertTo-Csv -NoType | Select-Object -Skip 1 | Set-Content "$rootPath\extract\$tableName.csv"

  Write-Output (-join('{"message": "info", "finished-csv": "', $tableName, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
}
