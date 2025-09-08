param caName string
param caeName string

param logAnalyticsWorkspaceName string
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalyticsWorkspaceName
}
param stNameBlob string
resource storageAccountBlob 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: stNameBlob
}

param stNameFile string
resource storageAccountFile 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: stNameFile
}

param kvName string
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: kvName
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

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' = {
  name: caeName
  location: resourceGroup().location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        dynamicJsonColumns: false
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
        enableFips: false
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false
      }
    }
    publicNetworkAccess: 'Enabled'
    vnetConfiguration: {
      infrastructureSubnetId: subnet.id
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource storage_langfuse_clickhouse_data 'storages@2025-02-02-preview' = {
    name: 'langfuse-clickhouse-data'
    properties: {
      nfsAzureFile: {
        server: replace(replace(storageAccountFile.properties.primaryEndpoints.file, 'https://', ''), '/', '')
        shareName: '/${storageAccountFile.name}/langfuse-clickhouse-data'
        accessMode: 'ReadWrite'
      }
    }
  }

  resource storage_langfuse_clickhouse_server 'storages@2025-02-02-preview' = {
    name: 'langfuse-clickhouse-logs'
    properties: {
      nfsAzureFile: {
        server: replace(replace(storageAccountFile.properties.primaryEndpoints.file, 'https://', ''), '/', '')
        shareName: '/${storageAccountFile.name}/langfuse-clickhouse-logs'
        accessMode: 'ReadWrite'
      }
    }
  }
}

var clickhouseUser = 'clickhouse'
var clickhousePassword = 'clickhouse'
param psqlName string
resource containerApps 'Microsoft.App/containerapps@2025-02-02-preview' = {
  name: caName
  location: resourceGroup().location
  kind: 'containerapps'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerAppsEnvironment.id
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 3000
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
      identitySettings: []
      maxInactiveRevisions: 100
      secrets: [
        {
          name: 'clickhouse-password'
          value: clickhousePassword
        }
        {
          name: 'redis-password'
          value: uniqueString('redis-password', resourceGroup().id)
        }
        {
          name: 'postgres-connection-string'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/${psqlName}-connection-string'
          identity: 'system'
        }
        {
          name: 'redis-connection-string'
          value: 'redis://default:${uniqueString('redis-password', resourceGroup().id)}@localhost:6379/0'
        }
        {
          name: '${storageAccountBlob.name}-key1'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/${storageAccountBlob.name}-key1'
          identity: 'system'
        }
        {
          name: 'langfuse-salt'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/langfuse-salt'
          identity: 'system'
        }
        {
          name: 'langfuse-encryption-key'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/langfuse-encryption-key'
          identity: 'system'
        }
        {
          name: 'nextauth-secret'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/langfuse-nextauth-secret'
          identity: 'system'
        }
        {
          name: 'nextauth-url'
          value: 'https://${caName}.${containerAppsEnvironment.properties.defaultDomain}'
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/langfuse/langfuse:3' // OR 'docker.io/langfuse/langfuse:3'
          imageType: 'ContainerImage'
          name: 'langfuse-web'
          env: [
            {
              name: 'REDIS_CONNECTION_STRING'
              secretRef: 'redis-connection-string'
            }
            {
              name: 'DATABASE_URL'
              secretRef: 'postgres-connection-string'
            }
            {
              name: 'CLICKHOUSE_CLUSTER_ENABLED'
              value: 'false'
            }
            {
              name: 'CLICKHOUSE_USER'
              value: clickhouseUser
            }
            {
              name: 'CLICKHOUSE_PASSWORD'
              secretRef: 'clickhouse-password'
            }
            {
              name: 'CLICKHOUSE_URL'
              value: 'http://localhost:8123'
            }
            {
              name: 'CLICKHOUSE_MIGRATION_URL'
              value: 'clickhouse://localhost:9000'
            }
            {
              name: 'LANGFUSE_USE_AZURE_BLOB'
              value: 'true'
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_BUCKET'
              value: 'langfuse'
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT'
              value: storageAccountBlob.properties.primaryEndpoints.blob
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID'
              value: storageAccountBlob.name
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY'
              secretRef: '${storageAccountBlob.name}-key1'
            }
            {
              name: 'NEXTAUTH_SECRET'
              secretRef: 'nextauth-secret'
            }
            {
              name: 'NEXTAUTH_URL'
              secretRef: 'nextauth-url'
            }
            {
              name: 'ENCRYPTION_KEY'
              secretRef: 'langfuse-encryption-key'
            }
            {
              name: 'SALT'
              secretRef: 'langfuse-salt'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: []
        }
        {
          image: 'ghcr.io/langfuse/langfuse-worker:3' // OR 'docker.io/langfuse/langfuse-worker:3'
          imageType: 'ContainerImage'
          name: 'langfuse-worker'
          env: [
            {
              name: 'REDIS_CONNECTION_STRING'
              secretRef: 'redis-connection-string'
            }
            {
              name: 'DATABASE_URL'
              secretRef: 'postgres-connection-string'
            }
            {
              name: 'CLICKHOUSE_CLUSTER_ENABLED'
              value: 'false'
            }
            {
              name: 'CLICKHOUSE_USER'
              value: clickhouseUser
            }
            {
              name: 'CLICKHOUSE_PASSWORD'
              secretRef: 'clickhouse-password'
            }
            {
              name: 'CLICKHOUSE_URL'
              value: 'http://localhost:8123'
            }
            {
              name: 'CLICKHOUSE_MIGRATION_URL'
              value: 'clickhouse://localhost:9000'
            }
            {
              name: 'LANGFUSE_USE_AZURE_BLOB'
              value: 'true'
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_BUCKET'
              value: 'langfuse'
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT'
              value: storageAccountBlob.properties.primaryEndpoints.blob
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID'
              value: storageAccountBlob.name
            }
            {
              name: 'LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY'
              secretRef: '${storageAccountBlob.name}-key1'
            }
            {
              name: 'NEXTAUTH_SECRET'
              secretRef: 'nextauth-secret'
            }
            {
              name: 'NEXTAUTH_URL'
              secretRef: 'nextauth-url'
            }
            {
              name: 'ENCRYPTION_KEY'
              secretRef: 'langfuse-encryption-key'
            }
            {
              name: 'SALT'
              secretRef: 'langfuse-salt'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: []
        }
        {
          image: 'docker.io/clickhouse/clickhouse-server'
          imageType: 'ContainerImage'
          name: 'clickhouse'
          env: [
            {
              name: 'CLICKHOUSE_USER'
              value: clickhouseUser
            }
            {
              name: 'CLICKHOUSE_PASSWORD'
              secretRef: 'clickhouse-password'
            }
            {
              name: 'CLICKHOUSE_DB'
              value: 'default'
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: []
          volumeMounts: [
            {
              volumeName: 'langfuse-clickhouse-data'
              mountPath: '/var/lib/clickhouse'
            }
            {
              volumeName: 'langfuse-clickhouse-logs'
              mountPath: '/var/log/clickhouse-server'
            }
          ]
        }
        {
          image: 'docker.io/redis:7' // OR 'mcr.microsoft.com/mirror/docker/library/redis:7.2'
          imageType: 'ContainerImage'
          name: 'redis'
          env: [
            {
              name: 'REDIS_PASSWORD'
              secretRef: 'redis-password'
            }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
        cooldownPeriod: 300
        pollingInterval: 30
      }
      volumes: [
        {
          name: 'langfuse-clickhouse-data'
          storageType: 'NfsAzureFile'
          storageName: 'langfuse-clickhouse-data'
        }
        {
          name: 'langfuse-clickhouse-logs'
          storageType: 'NfsAzureFile'
          storageName: 'langfuse-clickhouse-logs'
        }
      ]
    }
  }
}

var roleId = '4633458b-17de-408a-b874-0445c86b69e6' // https://learn.microsoft.com/ja-jp/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, roleId, containerApps.id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: containerApps.identity.principalId
    principalType: 'ServicePrincipal'
    scope: resourceGroup().id
  }
}
