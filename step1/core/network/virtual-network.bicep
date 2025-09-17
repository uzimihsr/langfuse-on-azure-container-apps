param name string
param vnetAddressPrefix string
param subnetNameContainerAppsEnvironment string
param subnetAddressPrefixContainerAppsEnvironment string
param subnetNamePrivateEndpointContainerApps string
param subnetAddressPrefixPrivateEndpointContainerApps string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: name
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
          serviceEndpoints: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: subnetNamePrivateEndpointContainerApps
        properties: {
          addressPrefixes: [
            subnetAddressPrefixPrivateEndpointContainerApps
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
