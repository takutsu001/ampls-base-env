/*
------------------
param section
------------------
*/

param location string
param hubVNetName string 
param myipaddress string
param hubVNetAddress string
// VM Subnet
param hubSubnetName2 string
param hubSubnetAddress2 string
// Private Endpoint Subnet
param hubSubnetName3 string
param hubSubnetAddress3 string
// for VM
param hubvmName1 string
param vmSizeWindows string
@secure()
param adminUserName string
@secure()
param adminPassword string
// ----param for LAW----
param lawName string
// ----param for Spot VM----
param useSpot bool = false

/*
------------------
var section
------------------
*/

var hubSubnet2 = { 
    name: hubSubnetName2 
    properties: { 
      addressPrefix: hubSubnetAddress2
      networkSecurityGroup: {
      id: nsgDefault.id
    }
  } 
}
var hubSubnet3 = { 
    name: hubSubnetName3 
    properties: { 
      addressPrefix: hubSubnetAddress3
      networkSecurityGroup: {
      id: nsgDefault.id
    }
  } 
} 

var vmPriorityProps = useSpot ? {
  priority: 'Spot'
  evictionPolicy: 'Deallocate'
  billingProfile: {
    maxPrice: -1
  }
} : {
  priority: 'Regular'
}

/*
------------------
resource section
------------------
*/

// create network security group for hub vnet
resource nsgDefault 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'hub-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP'
        properties: {
        description: 'RDP access permission from your own PC.'
        protocol: 'TCP'
        sourcePortRange: '*'
        destinationPortRange: '3389'
        sourceAddressPrefix: myipaddress
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 1000
        direction: 'Inbound'
      }
    }
  ]
}
}

// create hubVNet & hubSubnet
resource hubVNet 'Microsoft.Network/virtualNetworks@2021-05-01' = { 
  name: hubVNetName 
  location: location 
  properties: { 
    addressSpace: { 
      addressPrefixes: [ 
        hubVNetAddress 
      ] 
    } 
    subnets: [ 
      hubSubnet2
      hubSubnet3
    ]
  }
  // Get subnet information where VMs are connected.
  resource hubVMSubnet 'subnets' existing = {
    name: hubSubnetName2
  }
}

// create VM in hubVNet
// create public ip address for Windows VM
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: '${hubvmName1}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: hubvmName1
    }
  }
}

// create network interface for Windows VM
resource networkInterface 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${hubvmName1}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: hubVNet::hubVMSubnet.id
          }
        }
      }
    ]
  }
}

// create Windows vm in hub vnet
resource WindowsVM1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: hubvmName1
  location: location
  properties: union({
    hardwareProfile: {
      vmSize: vmSizeWindows
    }
    osProfile: {
      computerName: hubvmName1
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
       offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${hubvmName1}-disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }, vmPriorityProps)
}

// Create Log Analytics Workspace
resource LAW 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      //pay-as-you-go
      name: 'PerGB2018'
    }
    publicNetworkAccessForIngestion:'true'
    publicNetworkAccessForQuery: 'true'
    retentionInDays: 30
  }
}

/*
------------------
output section
------------------
*/

// return the private ip address of the vm to use from parent template
@description('return the private ip address of the vm to use from parent template')
output vmPrivateIp string = networkInterface.properties.ipConfigurations[0].properties.privateIPAddress
