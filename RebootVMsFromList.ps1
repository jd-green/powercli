## Logging Function
Function Log ($logText){
     $date = Get-Date
     Add-Content -Path "C:\Tools\reboots.log" -Value "$date    $logText" -Force
}

## Load PowerCLI Modules
add-pssnapin VMware.VimAutomation.Core
Log("PowerCLI snap-in loaded")

## Import Credentials
$CredFile = "C:\Tools\creds.xml"
$Cred = Get-VICredentialStoreItem -File $CredFile
Log("Imported VI credentials")

## Connect to vCenter server
$login = Connect-VIServer -Server <server> -User $Cred.User -Password $Cred.Password -WarningAction SilentlyContinue
Log("Connected to <server>")

## Read in List
$toRestart = Get-Content C:\Tools\ToRestart.txt
Log("Read in list. Rebooting:")
Log($toRestart)

## Shut down VMs
Write-Host "Stopping VMs..."
$toRestart | %{Shutdown-VMGuest $_ -Confirm:$false}
Log("Shut down all VMs")

## Pause for 5 minutes w/ countdown timer
Write-Host "Waiting 5 minutes..."
Log("Waiting 5 minutes")
$x = 5*60
$length = $x / 100
while($x -gt 0) {
  $min = [int](([string]($x/60)).split('.')[0])
  $text = " " + $min + " minutes " + ($x % 60) + " seconds left"
  Write-Progress "Waiting for VMs to shut down" -status $text -perc ($x/$length)
  start-sleep -s 1
  $x--
}
Log("5 minutes is up!")

## Boot VMs
Write-Host "Starting VMs..."
$toRestart | %{Start-VM $_}
Log("All VMs started. Finished successfully!") 