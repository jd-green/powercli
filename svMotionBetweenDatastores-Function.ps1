Function global:Migrate-DS{
<#
     .SYNOPSIS
          Moves VMs between datastores.

     .DESCRIPTION
          Moves VM's from one datastore to another in a controlled fashion using svMotion.

     .PARAMETER vCenter
          The FQDN of the vCenter server to connect to.
         
     .PARAMETER Source
          The datastore to copy VMs from.
         
     .PARAMETER Destination
          The datastore to copy VMs to.

     .EXAMPLE
          PS C:\> Migrate-DS -vCenter VC01.company.local -Source ds01 -Destination ds02

     .EXAMPLE
          PS C:\> Migrate-DS VC01 ds01 ds02
#>
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1,
  HelpMessage="Enter a valid vCenter server to connect to.")]
   [string]$vCenter,
    
  [Parameter(Mandatory=$True,Position=2,
  HelpMessage="Enter a valid source datastore.")]
   [string]$Source,

  [Parameter(Mandatory=$True,Position=3,
  HelpMessage="Enter a valid destination datastore.")]
   [string]$Destination
)
$ErrorActionPreference= 'silentlycontinue'
Function Log ($logText){
     $date = Get-Date
     Add-Content -Path "Migration Log - $Source to $Destination.log" -Value "$date    $logText" -Force
}

Log("Moving all VMs from $Source to $Destination")

Connect-VIServer $vCenter -Force
Log("Connected to $vCenter")

$toMove = Get-VM -Datastore $Source
Write-Host `nMoving $toMove.Length VMs from $Source to $Destination -ForegroundColor Green
Write-Host `n
$numVM = $toMove.Length
Log("Moving $numVM VMs...")

$toMove | ForEach {
     $vm = $_.Name
     $date = Get-Date
     Write-Host Beginning move of $vm at $date
     Log("Beginning move of $vm")
     try {
          Get-VM $_ | Move-VM -Datastore $Destination -Confirm:$false > $null
          $date = Get-Date
          Write-Host Finished moving $vm at $date! -ForegroundColor Yellow
          Write-Host `n
          Log("Finished moving $vm")
          Add-Content -Path "Migration Log - $Source to $Destination.log" -Value " " -Force
     } catch {
          $date = Get-Date
          Write-Host "There was an error moving $vm at $date!" -ForegroundColor Red
          Write-Host `n
          Log("Error moving $vm")
          Add-Content -Path "Migration Log - $Source to $Destination.log" -Value " " -Force
     }
     }
    
Write-Host "Moved all VM's! Exiting..." -ForegroundColor Green
Log("Moved all VM's! Exiting...")
}