using 'main.bicep'

param resourceGroupName = 'AMPLS-RG'
param resourceGroupLocation = 'japaneast'
// ---- for Firewall Rule ----
// your ip address for RDP (ex. xxx.xxx.xxx.xxx)
param myipaddress = '<Public IP Address>'
// ---- param for Hub ----
param hubVNetName = 'Hub-VNet'
param hubVNetAddress = '10.0.0.0/16'
param hubSubnetName2 = 'Hub-VMSubnet'
param hubSubnetAddress2 = '10.0.0.0/24'
param hubSubnetName3 = 'Hub-PESubnet'
param hubSubnetAddress3 = '10.0.100.0/24'
param vmSizeWindows = 'Standard_B2ms'
// To set the DNS name of the public IP address, the vm name must be specified in lower case.
param hubvmName1 = 'hub-jump-win-01'
// ---- param for Spoke1 ----
param spoke1VNetName = 'Spoke1-VNet' 
param spoke1VNetAddress = '10.1.0.0/16'
param spoke1SubnetName1 = 'Spoke1-VMSubnet'
param spoke1SubnetAddress1 = '10.1.0.0/24' 
param vmSizeLinux = 'Standard_B1s'
param spoke1vmName1 = 'spoke1-centos-01'
// ---- Common param for VM ----
param adminUserName = 'cloudadmin'
param adminPassword = 'msjapan1!msjapan1!'
// param for LAW
param lawName = 'law-ampls'
