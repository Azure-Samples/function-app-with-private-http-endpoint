@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The base name to be appended to all provisioned resources.')
@maxLength(13)
param resourceBaseName string = uniqueString(resourceGroup().id)

@description('The id of the virtual network for virtual network integration.')
param virtualNetworkId string

@description('The id of the virtual network subnet to be used for private endpoints.')
param subnetPrivateEndpointId string

@description('The name of the virtual network subnet to be used for private endpoints.')
param subnetPrivateEndpointName string

@description('The name of the Azure Key Vault in which to create secrets related to the Azure Storage account.')
param keyVaultName string = ''

@description('The name of the Key Vault secret corresponding to the Azure Storage account connection string.')
param keyVaultConnectionStringSecretName string = ''

@description('The name of the storage account file share.')
param fileShareName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'storage${resourceBaseName}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'
    }
  }
}

resource storageAccountFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01' = {
  name: '${storageAccount.name}/default/${fileShareName}'
}

resource storageFilePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-${resourceBaseName}-file'
  location: location
  properties: {
    subnet: {
      id: subnetPrivateEndpointId
      name: subnetPrivateEndpointName
    }
    privateLinkServiceConnections: [
      {
        id: storageAccount.id
        name: 'plsc-${resourceBaseName}-file'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

resource storageBlobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-${resourceBaseName}-blob'
  location: location
  properties: {
    subnet: {
      id: subnetPrivateEndpointId
      name: subnetPrivateEndpointName
    }
    privateLinkServiceConnections: [
      {
        id: storageAccount.id
        name: 'plsc-${resourceBaseName}-blob'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource storageTablePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-${resourceBaseName}-table'
  location: location
  properties: {
    subnet: {
      id: subnetPrivateEndpointId
      name: subnetPrivateEndpointName
    }
    privateLinkServiceConnections: [
      {
        id: storageAccount.id
        name: 'plsc-${resourceBaseName}-table'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
  }
}

resource storageQueuePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-${resourceBaseName}-queue'
  location: location
  properties: {
    subnet: {
      id: subnetPrivateEndpointId
      name: subnetPrivateEndpointName
    }
    privateLinkServiceConnections: [
      {
        id: storageAccount.id
        name: 'plsc-${resourceBaseName}-queue'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
  }
}

resource storageFilePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${environment().suffixes.storage}'
  location: 'Global'
}

resource storageBlobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'Global'
}

resource storageTablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.table.${environment().suffixes.storage}'
  location: 'Global'
}

resource storageQueuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.queue.${environment().suffixes.storage}'
  location: 'Global'
}

resource storageFileDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageFilePrivateDnsZone
  name: '${storageFilePrivateDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource storageBlobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageBlobPrivateDnsZone
  name: '${storageBlobPrivateDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource storageTableDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageTablePrivateDnsZone
  name: '${storageTablePrivateDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource storageQueueDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: storageQueuePrivateDnsZone
  name: '${storageQueuePrivateDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource storageFilePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageFilePrivateEndpoint
  name: 'filePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageFilePrivateDnsZone.id
        }
      }
    ]
  }
}

resource storageBlobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageBlobPrivateEndpoint
  name: 'blobPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageBlobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource storageTablePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageTablePrivateEndpoint
  name: 'tablePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageTablePrivateDnsZone.id
        }
      }
    ]
  }
}

resource storageQueuePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: storageQueuePrivateEndpoint
  name: 'tablePrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: storageQueuePrivateDnsZone.id
        }
      }
    ]
  }
}

// Azure Bicep currently (as of February 2022) does not support a secure output mechanism for Bicep templates or modules.
// Please refer to https://github.com/Azure/bicep/issues/2163 for additional information.
// 
// The Azure Bicep linter rightfully warns that Bicep modules/templates should not output
// secrets (see https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/linter-rule-outputs-should-not-contain-secrets).
// 
// In an attempt to work around the lack of a secure output mechanism, this module adopts an approach to
// set the secret (the Azure Storage connection string) into Key Vault.  A reference to Key Vault is optionally
// provided.  If provided, the secret is added to Key Vault, and the secret URI is set as output.  Doing so
// allows a consuming template to use the Key Vault secret (instead of directly using the Azure Storage connection string).

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = if (!empty(keyVaultName) && !empty(keyVaultConnectionStringSecretName)) {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = if (!empty(keyVaultName) && !empty(keyVaultConnectionStringSecretName)) {
  name: keyVaultConnectionStringSecretName
  parent: keyVault
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
}

output storageAccountConnectionStringSecretUriWithVersion string = secret.properties.secretUriWithVersion
