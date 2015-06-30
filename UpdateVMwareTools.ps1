## Global Variables - MODIFY THESE

$vCenter = "VAVC02.virtadmin.local"        #This is the vCenter to connect to
$CredFile = "C:\Tools\creds.xml"        #This is the path to the encrypted credentials file
$upgradeListPath = "C:\Tools\ToUpgrade.txt"

## DO NOT MODIFY BELOW THIS LINE

$ErrorActionPreference = ‘Stop’
## Logging Function
Function Log ($logText){
     $date = Get-Date
     Add-Content -Path "C:\Tools\VMToolsUpgrades.log" -Value "$date    $logText" -Force
}

## Load PowerCLI Modules
#add-pssnapin VMware.VimAutomation.Core
#Log("PowerCLI snap-in loaded")

## Import Credentials
#$Cred = Get-VICredentialStoreItem -File $CredFile
#Log("Imported VI credentials")

## Connect to vCenter server
#-User $Cred.User -Password $Cred.Password 
Connect-VIServer -Server $vCenter -WarningAction SilentlyContinue
Log("Connected to vCenter")

## Read in List
$toUpgrade = Get-Content -Path $upgradeListPath
Log("Read in list. Beginning VMware Tools upgrades on...:")
Log($toUpgrade)

## Upgrade VM Tools
Write-Host "Beginning upgrade of VMware tools on VMs..."
$toUpgrade | %{
    Write-Host "Attempting VMware Tools upgrade on $_"
    try 
    {
    Get-VM $_ | Update-Tools -NoReboot -ErrorAction Stop
    Write-Host "Initiated VMware Tools upgrade on $_" -ForegroundColor Green
    Log("Initiated VMware Tools upgrade on $_")
    Start-Sleep -s 30
    }
    catch
    {
            $date = Get-Date
            Write-Host "There was an error upgrading this VM at $date!" -ForegroundColor Red
            Write-Host `n
            Log("There was an ERROR upgrading VMware Tools on $_")
    }
}

Write-Host "All possible upgrades initiated! Exiting..."
Log("All upgrades initiated! Exiting...")
