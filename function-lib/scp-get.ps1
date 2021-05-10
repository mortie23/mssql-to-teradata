# Author: Christopher Mortimer
# Date:   2020-08-25
# Desc:   Powershell script to download files from the SFTP server
# Usage:  Add this line to your Powershell script to include
#         . .\function-lib\scp-get.ps1

$timestampLocal = $(Get-TimeStamp) 
function scpGet($rootPath) {
  Write-Output (-join('{"function" : "', ("{0}" -f $MyInvocation.MyCommand), '", "timestamp": "', $timestampLocal,'"}')) `
    | Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
  Write-Output (-join('{"message": "parameter", "rootPath": "', $rootPath, '"}')) `
    | Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append

  try {
    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
    # Setup variables
    $localPath = "$rootPath\extract-compress\"
    $remotePath = "/home/$SFTPUser/etl-extract/extract-compress/"
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
      # Download files.
      $transferOptions = New-Object winscp.TransferOptions
      $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
      $transferResult = $session.GetFiles($remotePath + "*.*", "$localPath", $false, $transferOptions)
      # Thow an error.
      $transferResult.Check()
      # Print results of transfer.
      foreach ($transfer in $transferResult.Transfers) {
        Write-Output (-join('{"download-success" : "', ("{0}" -f $transfer.FileName), '"}')) `
          | Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
      }
    }
    finally {
      # Disconnect, clean up
      $session.Dispose()
    }
    Write-Output (-join('{"message": "finished-scp"}')) `
      | Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
  }
  catch [Exception] {
    Write-Output $_.Exception.Message
    Write-Output (-join('{"message": "error-scp"}')) `
      | Tee-Object -file "$rootPath\logs\run_teradata_$timestamp.json" -Append
    exit 1
  }
}