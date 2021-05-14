echo "set connexion to private"
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff /f
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

echo "set static ip address"
Remove-NetIPAddress -InterfaceIndex $((Get-NetAdapter).ifIndex[0]) -Confirm:$false
$ipaddress = “192.168.0.249”
$ipprefix = “24”
$ipgw = "192.168.0.254"
$ipif = (Get-NetAdapter).ifIndex[0]
New-NetIPAddress -IPAddress $ipaddress -PrefixLength $ipprefix -InterfaceIndex $ipif -DefaultGateway $ipgw

#rename the computer
#$newname = “AD001”
#Rename-Computer -NewName $newname –force

echo "install features"
$addsTools = 'RSAT-AD-Tools'
Add-WindowsFeature $addsTools

echo "Install AD DS, DNS and GPMC"
start-job -Name addFeature -ScriptBlock {
Add-WindowsFeature -Name 'ad-domain-services' -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature -Name 'dns' -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature -Name 'gpmc' -IncludeAllSubFeature -IncludeManagementTools }
Wait-Job -Name addFeature

echo "Create New Forest, add Domain Controller"
$pass = ConvertTo-SecureString '@censi2021' -AsPlainText -Force
$domainname = 'mickael.com'
$netbiosName = 'MICKAEL'
Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath 'C:\Windows\NTDS' -DomainMode 'WinThreshold' -DomainName $domainname -DomainNetbiosName $netbiosName -ForestMode 'WinThreshold' -InstallDns:$true -LogPath 'C:\Windows\NTDS' -NoRebootOnCompletion:$false -SafeModeAdministratorPassword $pass -Force:$true