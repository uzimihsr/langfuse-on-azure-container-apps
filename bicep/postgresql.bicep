param psqlName string

param psqlAdminUserName string = 'postgresql'
param psqlAdminUserLoginPassword string = uniqueString('postgres-password', resourceGroup().id)

resource postgreSql 'Microsoft.DBforPostgreSQL/flexibleServers@2025-01-01-preview' = {
  name: psqlName
  location: resourceGroup().location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    replica: {
      role: 'Primary'
    }
    storage: {
      iops: 120
      tier: 'P4'
      storageSizeGB: 32
      autoGrow: 'Enabled'
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    authConfig: {
      activeDirectoryAuth: 'Disabled'
      passwordAuth: 'Enabled'
    }
    version: '17'
    administratorLogin: psqlAdminUserName
    administratorLoginPassword: psqlAdminUserLoginPassword
    availabilityZone: '2'
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    replicationRole: 'Primary'
  }
}

param kvName string
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: kvName
}
resource psqlLoginPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: '${psqlName}-connection-string'
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: 'postgresql://${psqlAdminUserName}:${psqlAdminUserLoginPassword}@${postgreSql.properties.fullyQualifiedDomainName}:5432/langfuse'
  }
}

param vnetName string
param subnetName string
param pepName string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: vnet
  name: subnetName
}

var privateDnsZoneName = 'privatelink.postgres.database.azure.com'
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}

  resource virtualNetworkLink 'virtualNetworkLinks@2024-06-01' = {
    name: vnet.name
    location: 'global'
    properties: {
      registrationEnabled: true
      virtualNetwork: {
        id: vnet.id
      }
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: pepName
  location: resourceGroup().location
  properties: {
    privateLinkServiceConnections: [
      {
        name: pepName
        properties: {
          privateLinkServiceId: postgreSql.id
          groupIds: [
            'postgresqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }

  resource privateDnsZoneGroup 'privateDnsZoneGroups@2024-07-01' = {
    name: pepName
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-postgres-database-azure-com'
          properties: {
            privateDnsZoneId: privateDnsZone.id
          }
        }
      ]
    }
  }
}
