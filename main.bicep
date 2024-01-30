targetScope = 'subscription'

/*
------------------
param section
------------------
*/
// ---- param for Common ----
param resourceGroupName string
param resourceGroupLocation string
param myipaddress string
// ----param for Hub----
param hubVNetName string
param hubVNetAddress string
// VM Subnet
param hubSubnetName2 string 
param hubSubnetAddress2 string
// Private Endpoint Subnet
param hubSubnetName3 string
param hubSubnetAddress3 string
// ----param for Spoke1----
param spoke1VNetName string 
param spoke1VNetAddress string
// VM Subnets
param spoke1SubnetName1 string
param spoke1SubnetAddress1 string
// ----param for VM----
param vmSizeWindows string
param vmSizeLinux string
param spoke1vmName1 string
param hubvmName1 string
@secure()
param adminUserName string
@secure()
param adminPassword string
// ----param for LAW----
param lawName string

/*
------------------
resource section
------------------
*/

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = { 
  name: resourceGroupName 
  location: resourceGroupLocation 
} 

/*
---------------
module section
---------------
*/

// Create Hub Environment (VM-Windows VNet, Subnet, NSG, LAW)
module HubModule './modules/hubEnv.bicep' = { 
  scope: newRG 
  name: 'CreateHubEnv' 
  params: { 
    location: resourceGroupLocation
    hubVNetName: hubVNetName
    hubVNetAddress: hubVNetAddress
    myipaddress: myipaddress
    hubSubnetName2: hubSubnetName2
    hubSubnetAddress2: hubSubnetAddress2
    hubSubnetName3: hubSubnetName3
    hubSubnetAddress3: hubSubnetAddress3
    hubvmName1: hubvmName1
    vmSizeWindows: vmSizeWindows
    adminUserName: adminUserName
    adminPassword: adminPassword
    lawName: lawName
  } 
}

// Create Spoke1 Environment (VM-Linux, VNet, Subnet, Vnet Peering)
module Spoke1Module './modules/spoke1Env.bicep' = { 
  scope: newRG
  name: 'CreateSpoke1Env'
  params: {
    location: resourceGroupLocation
    hubVNetName: hubVNetName
    spoke1VNetName: spoke1VNetName
    spoke1VNetAddress: spoke1VNetAddress
    spoke1SubnetName1: spoke1SubnetName1
    spoke1SubnetAddress1: spoke1SubnetAddress1
    spoke1vmName1: spoke1vmName1
    vmSizeLinux: vmSizeLinux
    adminUserName: adminUserName
    adminPassword: adminPassword
  } 
}
