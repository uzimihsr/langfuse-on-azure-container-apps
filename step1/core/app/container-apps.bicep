param name string
param containerAppsEnvironmentName string
param keyVaultName string

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' existing = {
  name: containerAppsEnvironmentName
}
resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: keyVaultName
}

var nextauthUrl = 'https://${name}.${containerAppsEnvironment.properties.defaultDomain}'
param postgresVersion string = 'latest'
param postgresUser string
param postgresDb string
param telemetryEnabled string
param langfuseEnableExperimentalFeatures string
param clickhouseDb string = 'default'
param clickhouseMigrationUrl string
param clickhouseUrl string
param clickhouseUser string
@secure()
param clickhousePassword string
param clickhouseClusterEnabled string
param minioRootUser string = 'minio'
param langfuseUseAzureBlob string
param langfuseS3EventUploadBucket string
param langfuseS3EventUploadRegion string
param langfuseS3EventUploadAccessKeyId string
@secure()
param langfuseS3EventUploadSecretAccessKey string
param langfuseS3EventUploadEndpoint string
param langfuseS3EventUploadForcePathStyle string
param langfuseS3EventUploadPrefix string
param langfuseS3MediaUploadBucket string
param langfuseS3MediaUploadRegion string
param langfuseS3MediaUploadAccessKeyId string
@secure()
param langfuseS3MediaUploadSecretAccessKey string
param langfuseS3MediaUploadEndpoint string
param langfuseS3MediaUploadForcePathStyle string
param langfuseS3MediaUploadPrefix string
param langfuseS3BatchExportEnabled string
param langfuseS3BatchExportBucket string
param langfuseS3BatchExportPrefix string
param langfuseS3BatchExportRegion string
param langfuseS3BatchExportEndpoint string
param langfuseS3BatchExportExternalEndpoint string
param langfuseS3BatchExportAccessKeyId string
@secure()
param langfuseS3BatchExportSecretAccessKey string
param langfuseS3BatchExportForcePathStyle string
param langfuseIngestionQueueDelayMs string
param langfuseIngestionClickhouseWriteIntervalMs string
param redisHost string
param redisPort string
@secure()
param redisAuth string
param redisTlsEnabled string
param redisTlsCa string
param redisTlsCert string
param redisTlsKey string
param emailFromAddress string
param smtpConnectionUrl string
param langfuseInitOrgId string
param langfuseInitOrgName string
param langfuseInitProjectId string
param langfuseInitProjectName string
param langfuseInitProjectPublicKey string
@secure()
param langfuseInitProjectSecretKey string
param langfuseInitUserEmail string
param langfuseInitUserName string
@secure()
param langfuseInitUserPassword string

var langfuseWorkerEnv = [
  { name: 'NEXTAUTH_URL', value: nextauthUrl }
  { name: 'DATABASE_URL', secretRef: 'database-url' }
  { name: 'SALT', secretRef: 'salt' }
  { name: 'ENCRYPTION_KEY', secretRef: 'encryption-key' }
  { name: 'TELEMETRY_ENABLED', value: telemetryEnabled }
  { name: 'LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES', value: langfuseEnableExperimentalFeatures }
  { name: 'CLICKHOUSE_MIGRATION_URL', value: clickhouseMigrationUrl }
  { name: 'CLICKHOUSE_URL', value: clickhouseUrl }
  { name: 'CLICKHOUSE_USER', value: clickhouseUser }
  { name: 'CLICKHOUSE_PASSWORD', secretRef: 'clickhouse-password' }
  { name: 'CLICKHOUSE_CLUSTER_ENABLED', value: clickhouseClusterEnabled }
  { name: 'LANGFUSE_USE_AZURE_BLOB', value: langfuseUseAzureBlob }
  { name: 'LANGFUSE_S3_EVENT_UPLOAD_BUCKET', value: langfuseS3EventUploadBucket }
  { name: 'LANGFUSE_S3_EVENT_UPLOAD_REGION', value: langfuseS3EventUploadRegion }
  { name: 'LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID', value: langfuseS3EventUploadAccessKeyId }
  {
    name: 'LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY'
    secretRef: 'langfuse-s3-event-upload-secret-access-key'
  }
  { name: 'LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT', value: langfuseS3EventUploadEndpoint }
  { name: 'LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE', value: langfuseS3EventUploadForcePathStyle }
  { name: 'LANGFUSE_S3_EVENT_UPLOAD_PREFIX', value: langfuseS3EventUploadPrefix }
  { name: 'LANGFUSE_S3_MEDIA_UPLOAD_BUCKET', value: langfuseS3MediaUploadBucket }
  { name: 'LANGFUSE_S3_MEDIA_UPLOAD_REGION', value: langfuseS3MediaUploadRegion }
  { name: 'LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID', value: langfuseS3MediaUploadAccessKeyId }
  {
    name: 'LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY'
    secretRef: 'langfuse-s3-media-upload-secret-access-key'
  }
  { name: 'LANGFUSE_S3_MEDIA_UPLOAD_ENDPOINT', value: langfuseS3MediaUploadEndpoint }
  { name: 'LANGFUSE_S3_MEDIA_UPLOAD_FORCE_PATH_STYLE', value: langfuseS3MediaUploadForcePathStyle }
  { name: 'LANGFUSE_S3_MEDIA_UPLOAD_PREFIX', value: langfuseS3MediaUploadPrefix }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_ENABLED', value: langfuseS3BatchExportEnabled }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_BUCKET', value: langfuseS3BatchExportBucket }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_PREFIX', value: langfuseS3BatchExportPrefix }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_REGION', value: langfuseS3BatchExportRegion }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_ENDPOINT', value: langfuseS3BatchExportEndpoint }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_EXTERNAL_ENDPOINT', value: langfuseS3BatchExportExternalEndpoint }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_ACCESS_KEY_ID', value: langfuseS3BatchExportAccessKeyId }
  {
    name: 'LANGFUSE_S3_BATCH_EXPORT_SECRET_ACCESS_KEY'
    secretRef: 'langfuse-s3-batch-export-secret-access-key'
  }
  { name: 'LANGFUSE_S3_BATCH_EXPORT_FORCE_PATH_STYLE', value: langfuseS3BatchExportForcePathStyle }
  { name: 'LANGFUSE_INGESTION_QUEUE_DELAY_MS', value: langfuseIngestionQueueDelayMs }
  {
    name: 'LANGFUSE_INGESTION_CLICKHOUSE_WRITE_INTERVAL_MS'
    value: langfuseIngestionClickhouseWriteIntervalMs
  }
  { name: 'REDIS_HOST', value: redisHost }
  { name: 'REDIS_PORT', value: redisPort }
  { name: 'REDIS_AUTH', secretRef: 'redis-auth' }
  { name: 'REDIS_TLS_ENABLED', value: redisTlsEnabled }
  { name: 'REDIS_TLS_CA', value: redisTlsCa }
  { name: 'REDIS_TLS_CERT', value: redisTlsCert }
  { name: 'REDIS_TLS_KEY', value: redisTlsKey }
  { name: 'EMAIL_FROM_ADDRESS', value: emailFromAddress }
  { name: 'SMTP_CONNECTION_URL', value: smtpConnectionUrl }
]

resource containerApps 'Microsoft.App/containerapps@2025-02-02-preview' = {
  name: name
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
          name: 'database-url'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/postgres-connection-string'
          identity: 'system'
        }
        { name: 'salt', keyVaultUrl: '${keyVault.properties.vaultUri}secrets/langfuse-salt', identity: 'system' }
        {
          name: 'encryption-key'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/langfuse-encryption-key'
          identity: 'system'
        }
        { name: 'clickhouse-password', value: clickhousePassword }
        { name: 'langfuse-s3-event-upload-secret-access-key', value: langfuseS3EventUploadSecretAccessKey }
        { name: 'langfuse-s3-media-upload-secret-access-key', value: langfuseS3MediaUploadSecretAccessKey }
        { name: 'langfuse-s3-batch-export-secret-access-key', value: langfuseS3BatchExportSecretAccessKey }
        { name: 'redis-auth', value: redisAuth }
        {
          name: 'nextauth-secret'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/langfuse-nextauth-secret'
          identity: 'system'
        }
        // { name: 'langfuse-init-project-secret-key', value: langfuseInitProjectSecretKey } // valueが空のSecretは作成できない
        // { name: 'langfuse-init-user-password', value: langfuseInitUserPassword } // valueが空のSecretは作成できない
        {
          name: 'minio-root-password'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/minio-root-password'
          identity: 'system'
        }
        {
          name: 'postgres-password'
          keyVaultUrl: '${keyVault.properties.vaultUri}secrets/postgres-password'
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'langfuse-worker'
          image: 'ghcr.io/langfuse/langfuse-worker:3' // OR 'docker.io/langfuse/langfuse-worker:3'
          imageType: 'ContainerImage'
          env: langfuseWorkerEnv
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: []
        }
        {
          name: 'langfuse-web'
          image: 'ghcr.io/langfuse/langfuse:3' // OR 'docker.io/langfuse/langfuse:3'
          imageType: 'ContainerImage'
          env: concat(langfuseWorkerEnv, [
            { name: 'NEXTAUTH_SECRET', secretRef: 'nextauth-secret' }
            { name: 'LANGFUSE_INIT_ORG_ID', value: langfuseInitOrgId }
            { name: 'LANGFUSE_INIT_ORG_NAME', value: langfuseInitOrgName }
            { name: 'LANGFUSE_INIT_PROJECT_ID', value: langfuseInitProjectId }
            { name: 'LANGFUSE_INIT_PROJECT_NAME', value: langfuseInitProjectName }
            { name: 'LANGFUSE_INIT_PROJECT_PUBLIC_KEY', value: langfuseInitProjectPublicKey }
            // { name: 'LANGFUSE_INIT_PROJECT_SECRET_KEY', secretRef: 'langfuse-init-project-secret-key' }
            { name: 'LANGFUSE_INIT_PROJECT_SECRET_KEY', value: langfuseInitProjectSecretKey }
            { name: 'LANGFUSE_INIT_USER_EMAIL', value: langfuseInitUserEmail }
            { name: 'LANGFUSE_INIT_USER_NAME', value: langfuseInitUserName }
            // { name: 'LANGFUSE_INIT_USER_PASSWORD', secretRef:'langfuse-init-user-password' }
            { name: 'LANGFUSE_INIT_USER_PASSWORD', value: langfuseInitUserPassword }
          ])
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: []
        }
        {
          name: 'clickhouse'
          image: 'docker.io/clickhouse/clickhouse-server'
          imageType: 'ContainerImage'
          // ACA does not support securityContext yet...
          env: [
            { name: 'CLICKHOUSE_DB', value: clickhouseDb }
            { name: 'CLICKHOUSE_USER', value: clickhouseUser }
            { name: 'CLICKHOUSE_PASSWORD', secretRef: 'clickhouse-password' }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: [] // command probe is not supported yet...
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
          name: 'minio'
          image: 'docker.io/minio/minio'
          imageType: 'ContainerImage'
          command: ['sh']
          // args: ['-c', '\'mkdir -p /data/langfuse && minio server --address ":9000" --console-address ":9001" /data\'']
          args: ['-c', 'mkdir -p /data/langfuse && minio server --address ":9090" --console-address ":9091" /data'] // ACAではminioとclickhouseでコンテナのポートが衝突してしまうので、9000→9090, 9001→9091に変更
          env: [
            { name: 'MINIO_ROOT_USER', value: minioRootUser }
            { name: 'MINIO_ROOT_PASSWORD', secretRef: 'minio-root-password' }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: [] // command probe is not supported yet...
          volumeMounts: [
            {
              volumeName: 'langfuse-minio-data'
              mountPath: '/data'
            }
          ]
        }
        {
          name: 'redis'
          image: 'docker.io/redis:7' // OR 'mcr.microsoft.com/mirror/docker/library/redis:7.2'
          imageType: 'ContainerImage'
          args: ['--requirepass', '${redisAuth}']
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: [] // command probe is not supported yet...
        }
        {
          name: 'postgres'
          image: 'docker.io/postgres:${postgresVersion}'
          imageType: 'ContainerImage'
          env: [
            { name: 'POSTGRES_USER', value: postgresUser }
            { name: 'POSTGRES_PASSWORD', secretRef: 'postgres-password' }
            { name: 'POSTGRES_DB', value: postgresDb }
          ]
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: []
          volumeMounts: [
            {
              volumeName: 'langfuse-postgres-data'
              mountPath: '/var/lib/postgresql/data'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
        cooldownPeriod: 300
        pollingInterval: 30
      }
      volumes: [
        {
          name: 'langfuse-postgres-data'
          storageType: 'EmptyDir'
        }
        {
          name: 'langfuse-clickhouse-data'
          storageType: 'EmptyDir'
        }
        {
          name: 'langfuse-clickhouse-logs'
          storageType: 'EmptyDir'
        }
        {
          name: 'langfuse-minio-data'
          storageType: 'EmptyDir'
        }
      ]
    }
  }
}

var roleId = '4633458b-17de-408a-b874-0445c86b69e6' // https://learn.microsoft.com/ja-jp/azure/role-based-access-control/built-in-roles/security#key-vault-secrets-user
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, roleId, containerApps.id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: containerApps.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
