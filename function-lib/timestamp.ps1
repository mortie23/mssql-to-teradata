# Author:   Christopher Mortimer
# Date:     2020-08-26
# Desc:     Powershell function to get a printable timestamp
# Usage:    Add this line to your Powershell script to include
#           . .\function-lib\compress.ps1
#           $timestamp = $(Get-TimeStamp) 

function Get-TimeStamp {
  return "{0:yyyyMMdd}_{0:HHmmss}" -f (Get-Date) 
}
