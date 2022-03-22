@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The base name to be appended to all provisioned resources.')
@maxLength(13)
param resourceBaseName string = uniqueString(resourceGroup().id)

@description('The name for the Azure virtual network to be created.')
param virtualNetworkName string

@description('The name of the virtual network subnet in which an Azure VM will be placed.')
param subnetVmName string

@description('The name of the virtual network subnet to be used for Azure App Service regional virtual network integration.')
param subnetAppServiceIntName string

@description('The name of the virtual network subnet to be used for private endpoints.')
param subnetPrivateEndpointName string

@description('The virtual network IP space to use for the new virutal network.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The IP space to use for the AzureBastionSubnet subnet.')
param bastionSubnetIpPrefix string = '10.0.1.0/24'

@description('The IP space to use for the subnet containing the virtual machine(s).')
param subnetVmAddressPrefix string = '10.0.2.0/24'

@description('The IP space to use for the subnet for Azure App Service regional virtual network integration.')
param subnetAppServiceIntAddressPrefix string = '10.0.3.0/24'

@description('The IP space to use for the subnet for private endpoints.')
param subnetPrivateEndpointAddressPrefix string = '10.0.4.0/24'

@description('The service types to enable service endpoints for on the App Service integration subnet.')
param subnetAppServiceIntServiceEndpointTypes array = []

var nsgName = 'nsg-${resourceBaseName}'

resource vmNsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${nsgName}-vm'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Block_RDP_Internet'
        properties: {
          description: 'Block RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 101
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource azureBastionNsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${nsgName}-bastion'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          description: 'Ingress traffic from public internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          description: 'Ingres traffic from Azure Bastion control plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          description: 'Ingress traffic from Azure Load Balancer'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunication'
        properties: {
          description: 'Ingress traffic from Azure Bastion data plane'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 150
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          description: 'Egress traffic to target VMs'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          priority: 100
          access: 'Allow'
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          description: 'Egress traffic to other public endpoints in Azure'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
          priority: 110
          access: 'Allow'
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          description: 'Egress traffic to Azure Bastion data plane'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          description: 'Egress traffic to internet'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '80'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource privateEndpointNsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${nsgName}-pe'
  location: location
}

resource appServiceIntegrationNsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${nsgName}-appServiceInt'
  location: location
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        // Azure Bastion requires the subnet to be named "AzureBastionSubnet".
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetIpPrefix
          networkSecurityGroup: {
            id: azureBastionNsg.id
          }
        }
      }
      {
        name: subnetVmName
        properties: {
          addressPrefix: subnetVmAddressPrefix
          networkSecurityGroup: {
            id: vmNsg.id
          }
        }
      }
      {
        name: subnetAppServiceIntName
        properties: {
          networkSecurityGroup: {
            id: appServiceIntegrationNsg.id
          }
          addressPrefix: subnetAppServiceIntAddressPrefix
          serviceEndpoints: [for service in subnetAppServiceIntServiceEndpointTypes: {
            service: service
            locations: [
              '*'
            ]
          }]
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: subnetPrivateEndpointName
        properties: {
          networkSecurityGroup: {
            id: privateEndpointNsg.id
          }
          addressPrefix: subnetPrivateEndpointAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output virtualNetworkId string = virtualNetwork.id
output subnetVmId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetVmName)
output subnetAppServiceIntId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetAppServiceIntName)
output subnetBastionId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'AzureBastionSubnet')
output subnetPrivateEndpointId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetPrivateEndpointName)
