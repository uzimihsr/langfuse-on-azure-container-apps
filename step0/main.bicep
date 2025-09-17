param logAnalyticsName string = 'log-${uniqueString(resourceGroup().id)}'
module logAnalytics './core/monitor/log-analytics.bicep' = {
  name: 'loganalytics-deployment'
  params: {
    name: logAnalyticsName
  }
}

param containerAppsEnvironmentName string = 'cae-${uniqueString(resourceGroup().id)}'
module containerAppsEnvironment './core/app/container-apps-environments.bicep' = {
  name: 'containerappsenv-deployment'
  params: {
    name: containerAppsEnvironmentName
    logAnalyticsWorkspaceName: logAnalyticsName
  }
  dependsOn: [
    logAnalytics
  ]
}

param containerAppName string = 'ca-${uniqueString(resourceGroup().id)}'
param telemetryEnabled string
param langfuseEnableExperimentalFeatures string
param clickhouseMigrationUrl string
param clickhouseUrl string
param clickhouseUser string
@secure()
param clickhousePassword string
param clickhouseClusterEnabled string
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
module containerApps './core/app/container-apps.bicep' = {
  name: 'containerapp-deployment'
  params: {
    name: containerAppName
    containerAppsEnvironmentName: containerAppsEnvironmentName
    telemetryEnabled: telemetryEnabled
    langfuseEnableExperimentalFeatures: langfuseEnableExperimentalFeatures
    clickhouseMigrationUrl: clickhouseMigrationUrl
    clickhouseUrl: clickhouseUrl
    clickhouseUser: clickhouseUser
    clickhousePassword: clickhousePassword
    clickhouseClusterEnabled: clickhouseClusterEnabled
    langfuseUseAzureBlob: langfuseUseAzureBlob
    langfuseS3EventUploadBucket: langfuseS3EventUploadBucket
    langfuseS3EventUploadRegion: langfuseS3EventUploadRegion
    langfuseS3EventUploadAccessKeyId: langfuseS3EventUploadAccessKeyId
    langfuseS3EventUploadSecretAccessKey: langfuseS3EventUploadSecretAccessKey
    langfuseS3EventUploadEndpoint: langfuseS3EventUploadEndpoint
    langfuseS3EventUploadForcePathStyle: langfuseS3EventUploadForcePathStyle
    langfuseS3EventUploadPrefix: langfuseS3EventUploadPrefix
    langfuseS3MediaUploadBucket: langfuseS3MediaUploadBucket
    langfuseS3MediaUploadRegion: langfuseS3MediaUploadRegion
    langfuseS3MediaUploadAccessKeyId: langfuseS3MediaUploadAccessKeyId
    langfuseS3MediaUploadSecretAccessKey: langfuseS3MediaUploadSecretAccessKey
    langfuseS3MediaUploadEndpoint: langfuseS3MediaUploadEndpoint
    langfuseS3MediaUploadForcePathStyle: langfuseS3MediaUploadForcePathStyle
    langfuseS3MediaUploadPrefix: langfuseS3MediaUploadPrefix
    langfuseS3BatchExportEnabled: langfuseS3BatchExportEnabled
    langfuseS3BatchExportBucket: langfuseS3BatchExportBucket
    langfuseS3BatchExportPrefix: langfuseS3BatchExportPrefix
    langfuseS3BatchExportRegion: langfuseS3BatchExportRegion
    langfuseS3BatchExportEndpoint: langfuseS3BatchExportEndpoint
    langfuseS3BatchExportExternalEndpoint: langfuseS3BatchExportExternalEndpoint
    langfuseS3BatchExportAccessKeyId: langfuseS3BatchExportAccessKeyId
    langfuseS3BatchExportSecretAccessKey: langfuseS3BatchExportSecretAccessKey
    langfuseS3BatchExportForcePathStyle: langfuseS3BatchExportForcePathStyle
    langfuseIngestionQueueDelayMs: langfuseIngestionQueueDelayMs
    langfuseIngestionClickhouseWriteIntervalMs: langfuseIngestionClickhouseWriteIntervalMs
    redisHost: redisHost
    redisPort: redisPort
    redisAuth: redisAuth
    redisTlsEnabled: redisTlsEnabled
    redisTlsCa: redisTlsCa
    redisTlsCert: redisTlsCert
    redisTlsKey: redisTlsKey
    emailFromAddress: emailFromAddress
    smtpConnectionUrl: smtpConnectionUrl
    langfuseInitOrgId: langfuseInitOrgId
    langfuseInitOrgName: langfuseInitOrgName
    langfuseInitProjectId: langfuseInitProjectId
    langfuseInitProjectName: langfuseInitProjectName
    langfuseInitProjectPublicKey: langfuseInitProjectPublicKey
    langfuseInitProjectSecretKey: langfuseInitProjectSecretKey
    langfuseInitUserEmail: langfuseInitUserEmail
    langfuseInitUserName: langfuseInitUserName
    langfuseInitUserPassword: langfuseInitUserPassword
  }
  dependsOn: [
    containerAppsEnvironment
  ]
}
