# deploy-langfuse-on-azure-app-service

## deploy

```bash
rgName="langfuse-1234" # change me
az group create --name $rgName --location japaneast
az deployment group create -g $rgName -f ./bicep/main.bicep
```
