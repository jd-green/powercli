$hosts = Get-Cluster [CLUSTER HERE] | Get-VMHost
$versions = @{}
foreach($vihost in $hosts){
  $esxcli = get-vmhost $vihost | Get-EsxCli
  $versions.Add($vihost, ($esxcli.system.module.get("enic") | select Version))
}
$versions.GetEnumerator() | Sort Name