param vnetName string
param vnetAddressPrefix string
param subnetNameContainerAppsEnvironment string
param subnetAddressPrefixContainerAppsEnvironment string
param subnetNamePrivateEndpointPostgreSql string
param subnetAddressPrefixPrivateEndpointPostgreSql string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    privateEndpointVNetPolicies: 'Disabled'
    subnets: [
      {
        name: subnetNameContainerAppsEnvironment
        properties: {
          addressPrefixes: [
            subnetAddressPrefixContainerAppsEnvironment
          ]
          delegations: [
            {
              name: 'Microsoft.App/environments'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.Storage'
              locations: [
                '*'
              ]
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: subnetNamePrivateEndpointPostgreSql
        properties: {
          addressPrefixes: [
            subnetAddressPrefixPrivateEndpointPostgreSql
          ]
          delegations: []
          serviceEndpoints: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}
