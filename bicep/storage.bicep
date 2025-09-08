param stNameBlob string
param stNameFile string

param vnetName string
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vnetName
}
param subnetName string
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: vnet
  name: subnetName
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: stNameBlob
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: subnet.id
          action: 'Allow'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccountFile 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: stNameFile
  location: resourceGroup().location
  sku: {
    name: 'PremiumV2_LRS'
  }
  kind: 'FileStorage'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: subnet.id
          action: 'Allow'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: false
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }

  resource fileService 'fileServices@2025-01-01' = {
    name: 'default'
    properties: {
      protocolSettings: {
        smb: {
          multichannel: {
            enabled: true
          }
        }
      }
      cors: {
        corsRules: []
      }
      shareDeleteRetentionPolicy: {
        enabled: true
        days: 7
      }
    }

    resource fileShare_langfuse_clickhouse_data 'shares@2025-01-01' = {
      name: 'langfuse-clickhouse-data'
      properties: {
        provisionedIops: 4024
        provisionedBandwidthMibps: 228
        shareQuota: 1024
        enabledProtocols: 'NFS'
        rootSquash: 'NoRootSquash'
      }
    }

    resource fileShare_langfuse_clickhouse_logs 'shares@2025-01-01' = {
      name: 'langfuse-clickhouse-logs'
      properties: {
        provisionedIops: 4024
        provisionedBandwidthMibps: 228
        shareQuota: 1024
        enabledProtocols: 'NFS'
        rootSquash: 'NoRootSquash'
      }
    }
  }
}
