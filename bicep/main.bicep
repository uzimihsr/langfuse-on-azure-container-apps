param vnetName string = 'vnet-langfuse-${uniqueString(resourceGroup().id)}'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnetNameContainerAppsEnvironment string = 'snet-cae-${uniqueString(resourceGroup().id)}'
param subnetAddressPrefixContainerAppsEnvironment string = '10.0.2.0/23'
param subnetNamePrivateEndpointPostgreSql string = 'snet-pe-psql-${uniqueString(resourceGroup().id)}'
param subnetAddressPrefixPrivateEndpointPostgreSql string = '10.0.4.0/24'
module vnet './vnet.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetNameContainerAppsEnvironment: subnetNameContainerAppsEnvironment
    subnetAddressPrefixContainerAppsEnvironment: subnetAddressPrefixContainerAppsEnvironment
    subnetNamePrivateEndpointPostgreSql: subnetNamePrivateEndpointPostgreSql
    subnetAddressPrefixPrivateEndpointPostgreSql: subnetAddressPrefixPrivateEndpointPostgreSql
  }
}

param logName string = 'log-langfuse-${uniqueString(resourceGroup().id)}'
module loganalytics './loganalytics.bicep' = {
  name: 'loganalytics-deployment'
  params: {
    logName: logName
  }
}

param stNameFile string = 'stlffile${uniqueString(resourceGroup().id)}'
param stNameBlob string = 'stlfblob${uniqueString(resourceGroup().id)}'
module storage './storage.bicep' = {
  name: 'storage-deployment'
  params: {
    vnetName: vnetName
    subnetName: subnetNameContainerAppsEnvironment
    stNameBlob: stNameBlob
    stNameFile: stNameFile
  }
  dependsOn: [
    vnet
  ]
}

param psqlName string = 'psql-langfuse-${uniqueString(resourceGroup().id)}'
param psqlAdminUserName string = 'postgresql'
@secure()
param psqlAdminUserLoginPassword string
module postgresql './postgresql.bicep' = {
  name: 'postgresql-deployment'
  params: {
    psqlName: psqlName
    kvName: kvName
    vnetName: vnetName
    subnetName: subnetNamePrivateEndpointPostgreSql
    pepName: 'pep-${psqlName}'
    psqlAdminUserLoginPassword: psqlAdminUserLoginPassword
    psqlAdminUserName: psqlAdminUserName
  }
  dependsOn: [
    vnet
  ]
}

@secure()
param langfuseSalt string
@secure()
param langfuseEncryptionKey string
@secure()
param langfuseNextAuthSecret string
@secure()
param langfuseInitUserPassword string
param kvName string = 'kvlangfuse${uniqueString(resourceGroup().id)}'
module keyvault './keyvault.bicep' = {
  name: 'keyvault-deployment'
  params: {
    kvName: kvName
    storageAccountName: stNameBlob
    vnetName: vnetName
    subnetName: subnetNameContainerAppsEnvironment
    langfuseSalt: langfuseSalt
    langfuseEncryptionKey: langfuseEncryptionKey
    langfuseNextAuthSecret: langfuseNextAuthSecret
    langfuseInitUserPassword: langfuseInitUserPassword
  }
  dependsOn: [
    vnet
    storage
  ]
}

param caeName string = 'cae-langfuse-${uniqueString(resourceGroup().id)}'
param caName string = 'ca-langfuse-${uniqueString(resourceGroup().id)}'
param langfuseInitUserEmail string = 'user@example.com'
param langfuseInitUserName string = 'John Doe'
param langfuseInitOrgName string = 'My Org'
param langfuseInitProjectName string = 'My Project'
param clickhouseUser string = 'clickhouse'
@secure()
param clickhousePassword string
@secure()
param redisPassword string
module containerapps './containerapps.bicep' = {
  name: 'containerapps-deployment'
  params: {
    caeName: caeName
    caName: caName
    logAnalyticsWorkspaceName: logName
    stNameBlob: stNameBlob
    stNameFile: stNameFile
    kvName: kvName
    vnetName: vnetName
    clickhouseUser: clickhouseUser
    clickhousePassword: clickhousePassword
    redisPassword: redisPassword
    subnetName: subnetNameContainerAppsEnvironment
    psqlName: psqlName
    langfuseInitOrgName: langfuseInitOrgName
    langfuseInitProjectName: langfuseInitProjectName
    langfuseInitUserEmail: langfuseInitUserEmail
    langfuseInitUserName: langfuseInitUserName
  }
  dependsOn: [
    vnet
    storage
    keyvault
    postgresql
  ]
}
