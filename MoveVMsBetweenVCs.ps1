###### Modify these variables ###########
$srcVC = "XXXXXXXX"
$dstVC = "XXXXXXXX"
$srcCluster = "XXXXXXXX"
$dstCluster = "XXXXXXXX"
$srcDatastore = "XXXXXXXX"
$toMoveNames = "XXXXXXXX" ,"XXXXXXXX" ,"XXXXXXXX" ,"XXXXXXXX" #VMs to migrate
$vAppName = "XXXXXXXX"
#########################################

$toMovePaths = @()

#Create array of VM paths
#For($i=0; $i -le $toMoveNames.Length; $i++){
$toMoveNames | ForEach {
$toMovePaths += Get-Item ("vmstores:\" + $srcVC + "@443\" + $srcCluster + "\" + $srcDatastore + "\" + $_ + "\" + $_ + ".vmx" )
}

#Connect to both vCenters
Connect-VIServer $srcVC ,$dstVC

#Remove VMs from old vCenter
$toMoveNames | ForEach {
Remove-VM -Server $srcVC -VM $_ -Confirm: $false
Write-Host "Removed " $_" from old vCenter" -foregroundcolor yellow
}

#Add VMs to new vCenter
$toMovePaths | ForEach {
New-VM -ResourcePool $dstCluster -VMFilePath $_.DatastoreFullPath -Confirm:$false | Out-Null
}
Write-Host "Added all VMs to new vCenter" -foregroundcolor yellow

#Add VMs to vApp
$vApp = Get-VApp $vAppName
$toMoveNames | ForEach {
Move-VM -VM $_ -Destination $vApp | Out-Null
}
Write-Host "Added VMs to vApp " $vAppName"." -foregroundcolor yellow

Write-Host "Moving VMs complete!" -foregroundcolor green