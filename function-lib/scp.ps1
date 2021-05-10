# Author: Christopher Mortimer
# Date:   2020-08-25
# Desc:   Powershell script to copy files to the SFTP server
# Usage:  Add this line to your Powershell script to include
#         . .\function-lib\scp.ps1

$timestampLocal = $(Get-TimeStamp) 
function scp($rootPath) {
  Write-Output (-join('{"function" : "', ("{0}" -f $MyInvocation.MyCommand), '", "timestamp": "', $timestampLocal,'"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "rootPath": "', $rootPath, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append

  try {
    # Load WinSCP .NET assembly
    # TODO: This is not generic
    # Downloaded this from https://winscp.net/eng/downloads.php#additional
    # .NET assembly / COM library
    Add-Type -Path "C:\Program Files\WinSCP\WinSCPnet.dll"
    # Setup variables
    $localPath = "$rootPath\extract-compress\"
    $remotePath = "/home/$SFTPUser/etl-extract/"
    # Setup session options
    $sessionOptions = New-Object winscp.sessionoptions
    $sessionOptions.protocol = [WinSCP.Protocol]::sftp
    $sessionOptions.HostName = "$SFTPServer"
    $sessionOptions.username = "$SFTPUser"
    $sessionOptions.password = "$SFTPPassword"
    $sessionOptions.SshHostKeyFingerprint = "$SshHostKeyFingerprint"
    $session = New-Object WinSCP.Session

    try {
      # Connect
      $session.Open($sessionOptions)
      # Upload files.
      $transferOptions = New-Object winscp.TransferOptions
      $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
      $transferResult = $session.PutFiles("$localPath", $remotePath + "*.*", $false, $transferOptions)
      # Thow an error.
      $transferResult.Check()
      # Print results of transfer.
      foreach ($transfer in $transferResult.Transfers) {
        Write-Output (-join('{"upload-success" : "', ("{0}" -f $transfer.FileName), '"}')) `
          | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
      }
    }
    finally {
      # Disconnect, clean up
      $session.Dispose()
    }
    Write-Output (-join('{"message": "finished-scp"}')) `
      | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
  }
  catch [Exception] {
    Write-Output $_.Exception.Message
    Write-Output (-join('{"message": "error-scp"}')) `
      | Tee-Object -file "$rootPath\logs\run_mssql_$timestamp.json" -Append
    exit 1
  }
}