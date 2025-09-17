param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: keyVaultName
}

@secure()
param postgresPassword string
param postgresUser string
param postgresDb string
resource secretPostgresPassword 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'postgres-password'
  properties: {
    attributes: { enabled: true }
    contentType: 'string'
    value: postgresPassword
  }
}
resource secretPostgresConnectionString 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'postgres-connection-string'
  properties: {
    attributes: { enabled: true }
    contentType: 'string'
    value: 'postgresql://${postgresUser}:${postgresPassword}@localhost:5432/${postgresDb}'
  }
}

@secure()
param langfuseSalt string
resource secretLangfuseSalt 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'langfuse-salt'
  properties: {
    attributes: { enabled: true }
    contentType: 'string'
    value: langfuseSalt
  }
}

@secure()
param langfuseEncryptionKey string
resource secretLangfuseEncryptionKey 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'langfuse-encryption-key'
  properties: {
    attributes: { enabled: true }
    contentType: 'string'
    value: langfuseEncryptionKey
  }
}

@secure()
param langfuseNextAuthSecret string
resource secretLangfuseNextAuthSecret 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'langfuse-nextauth-secret'
  properties: {
    attributes: { enabled: true }
    contentType: 'string'
    value: langfuseNextAuthSecret
  }
}

@secure()
param minioRootPassword string
resource secretMinioRootPassword 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'minio-root-password'
  properties: {
    attributes: { enabled: true }
    contentType: 'string'
    value: minioRootPassword
  }
}
