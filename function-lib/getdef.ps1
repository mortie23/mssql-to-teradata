# Author:   Christopher Mortimer
# Date:     2020-08-24
# Desc:     Powershell function to get the definition of an SQL Server table to CSV.
# Usage:    Add this line to your Powershell script to include
#           . .\function-lib\expand.ps1

$timestampLocal = $(Get-TimeStamp) 
# SQL Query
function getDef($rootPath, $tableName) {
  Write-Output (-join('{"function" : "', ("{0}" -f $MyInvocation.MyCommand), '", "timestamp": "', $timestampLocal,'"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "tableName": "', $tableName, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append

  $SqlQuery = "
  SELECT 
    ORDINAL_POSITION
    , COLUMN_NAME
    , DATA_TYPE
    , CHARACTER_MAXIMUM_LENGTH
    , NUMERIC_PRECISION
    , NUMERIC_SCALE
    , IS_NULLABLE
  FROM 
    INFORMATION_SCHEMA.COLUMNS
  WHERE 
    TABLE_NAME = '$tableName'
  " 

  $SqlConnection = New-Object System.Data.SqlClient.SqlConnection  
  $SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True;"  
  $SqlCmd = New-Object System.Data.SqlClient.SqlCommand  
  $SqlCmd.CommandText = $SqlQuery  
  $SqlCmd.Connection = $SqlConnection  
  $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter  
  $SqlAdapter.SelectCommand = $SqlCmd   

  # Set the date format
  (Get-Culture).Clone().DateTimeFormat.ShortDatePattern="yyyy-MM-dd"
  # Export the data to file  
  $DataSet = New-Object System.Data.DataSet  
  $SqlAdapter.Fill($DataSet)  
  Write-Output (-join('{"message": "info", "writing-ddl": "', $tableName, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  # This method adds headers which Teradata tdload does not like
  # Not using tdload anymore for reasons, using full TPT now
  $DataSet.Tables[0] | export-csv -Delimiter ',' -Path "$rootPath\extract\ddl_$tableName.csv" -NoTypeInformation
  #$DataSet.Tables[0] | ConvertTo-Csv -NoType | Select-Object -Skip 1 | Set-Content "$rootPath\extract\$tableName.csv"

  Write-Output (-join('{"message": "info", "finished-ddl": "', $tableName, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
}
