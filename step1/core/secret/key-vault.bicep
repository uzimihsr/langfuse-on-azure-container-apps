param name string

param virtualNetworkName string
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: virtualNetworkName
}
param subnetName string
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: virtualNetwork
  name: subnetName
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: name
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: [
        {
          id: subnet.id
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
    accessPolicies: []
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
  }
}
