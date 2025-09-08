param kvName string = 'kv-langfuse-001-${uniqueString(resourceGroup().id)}'
param storageAccountName string
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}
param vnetName string
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vnetName
}
param subnetName string
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: vnet
  name: subnetName
}

@secure()
param langfuseSalt string
@secure()
param langfuseEncryptionKey string
@secure()
param langfuseNextAuthSecret string
@secure()
param langfuseInitUserPassword string
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: kvName
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

  resource secretStorageAccountKey1 'secrets@2024-12-01-preview' = {
    name: '${storageAccount.name}-key1'
    properties: {
      attributes: {
        enabled: true
      }
      contentType: 'string'
      value: storageAccount.listKeys().keys[0].value
    }
  }

  resource secretLangfuseSalt 'secrets@2024-12-01-preview' = {
    name: 'langfuse-salt'
    properties: {
      attributes: {
        enabled: true
      }
      contentType: 'string'
      value: langfuseSalt
    }
  }

  resource secretLangfuseEncryptionKey 'secrets@2024-12-01-preview' = {
    name: 'langfuse-encryption-key'
    properties: {
      attributes: {
        enabled: true
      }
      contentType: 'string'
      value: langfuseEncryptionKey
    }
  }

  resource secretLangfuseNextAuthSecret 'secrets@2024-12-01-preview' = {
    name: 'langfuse-nextauth-secret'
    properties: {
      attributes: {
        enabled: true
      }
      contentType: 'string'
      value: langfuseNextAuthSecret
    }
  }

  resource secretLangfuseInitUserPassword 'secrets@2024-12-01-preview' = {
    name: 'langfuse-init-user-password'
    properties: {
      attributes: {
        enabled: true
      }
      contentType: 'string'
      value: langfuseInitUserPassword
    }
  }
}
