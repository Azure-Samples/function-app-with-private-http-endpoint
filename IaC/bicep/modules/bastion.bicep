@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The base name to be appended to all provisioned resources.')
@maxLength(13)
param resourceBaseName string = uniqueString(resourceGroup().id)

@description('The name of the Azure Bastion resource.')
param bastionHostName string

@description('The Azure resource ID which uniquely identifies the subnet used for Azure Bastion.')
param bastionSubnetId string

@description('The name of the public IP address resource.')
param publicIpAddressName string = 'pip-${resourceBaseName}'

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: bastionSubnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}
