# Deploy Langfuse(v3) on Azure Container Apps

## deploy

```bash
rgName='langfuse-1234' # CHANGE ME!!!
psqlAdminUserLoginPassword='postgres' # CHANGE ME!!!
clickhousePassword='clickhouse' # CHANGE ME!!!
redisPassword='redis' # CHANGE ME!!!
langfuseInitUserPassword='password123#' # CHANGE ME!!!
langfuseSalt=$(openssl rand -base64 3 2>/dev/null || echo 'mysalt')
langfuseEncryptionKey=$(openssl rand -hex 32 2>/dev/null || echo '0000000000000000000000000000000000000000000000000000000000000000')
langfuseNextAuthSecret=$(openssl rand -base64 32 2>/dev/null || echo 'mysecret')
az group create --name $rgName --location japaneast
az deployment group create -g $rgName -f ./bicep/main.bicep -p \
  psqlAdminUserLoginPassword=$psqlAdminUserLoginPassword \
  clickhousePassword=$clickhousePassword \
  redisPassword=$redisPassword \
  langfuseSalt=$langfuseSalt \
  langfuseEncryptionKey=$langfuseEncryptionKey \
  langfuseNextAuthSecret=$langfuseNextAuthSecret \
  langfuseInitUserPassword=$langfuseInitUserPassword
```
