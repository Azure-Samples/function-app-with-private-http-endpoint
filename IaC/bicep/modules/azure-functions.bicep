@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The base name to be appended to all provisioned resources.')
@maxLength(13)
param resourceBaseName string = uniqueString(resourceGroup().id)

@description('The name of the Function App to provision.')
param azureFunctionAppName string

@description('Specifies if the Azure Function app is accessible via HTTPS only.')
param httpsOnly bool = false

@description('Set to true to cause all outbound traffic to be routed into the virtual network (traffic subjet to NSGs and UDRs). Set to false to route only private (RFC1918) traffic into the virtual network.')
param vnetRouteAllEnabled bool = false

@description('The id of the virtual network for virtual network integration.')
param virtualNetworkId string

@description('Specify the Azure Resource Manager ID of the virtual network and subnet to be joined by regional vnet integration.')
param subnetAppServiceIntegrationId string

@description('The id of the virtual network subnet to be used for private endpoints.')
param subnetPrivateEndpointId string

@description('The built-in runtime stack to be used for a Linux-based Azure Function. This value is ignore if a Windows-based Azure Function hosting plan is used. Get the full list by executing the "az webapp list-runtimes --linux" command.')
param linuxRuntime string = 'DOTNET|6.0'

resource azureFunctionPlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: 'plan-${resourceBaseName}'
  location: location
  kind: 'elastic'
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
    size: 'EP1'
  }
  properties: {
    maximumElasticWorkerCount: 20
    reserved: true
  }
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: azureFunctionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    httpsOnly: httpsOnly
    serverFarmId: azureFunctionPlan.id
    reserved: true
    virtualNetworkSubnetId: subnetAppServiceIntegrationId
    siteConfig: {
      vnetRouteAllEnabled: vnetRouteAllEnabled
      functionsRuntimeScaleMonitoringEnabled: true
      linuxFxVersion: linuxRuntime
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource config 'config' = {
    name: 'web'
    properties: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

resource functionPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: 'pe-${resourceBaseName}-sites'
  location: location
  properties: {
    subnet: {
      id: subnetPrivateEndpointId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${resourceBaseName}-sites'
        properties: {
          privateLinkServiceId: azureFunction.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource functionPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

resource functionPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: functionPrivateDnsZone
  name: '${functionPrivateDnsZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource functionPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: functionPrivateEndpoint
  name: 'functionPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: functionPrivateDnsZone.id
        }
      }
    ]
  }
}

output azureFunctionTenantId string = azureFunction.identity.tenantId
output azureFunctionPrincipalId string = azureFunction.identity.principalId
output azureFunctionId string = azureFunction.id
