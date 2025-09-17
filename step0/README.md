# deploy

```bash
rgName='langfuse-1234' # CHANGE ME!!!
az group create --name $rgName --location japaneast
az deployment group create \
  -g $rgName \
  -f main.bicep \
  -p main.bicepparam
```

# test

```bash
python -m env ./testenv
source ./testenv/bin/activate
pip install langfuse openai

export LANGFUSE_SECRET_KEY="sk-lf-..."
export LANGFUSE_PUBLIC_KEY="pk-lf-..."
export LANGFUSE_HOST="https://{name}.{hash}.{region}.azurecontainerapps.io"

export AZURE_OPENAI_KEY=""
export AZURE_ENDPOINT=""
export AZURE_DEPLOYMENT_NAME="gpt-5-nano" # example deployment name

python
```

```python
import os
from langfuse.openai import AzureOpenAI

client = AzureOpenAI(
    api_key=os.getenv("AZURE_OPENAI_KEY"),  
    api_version="2023-03-15-preview",
    azure_endpoint=os.getenv("AZURE_ENDPOINT")
)

client.chat.completions.create(
  name="test-chat-azure-openai",
  model=os.getenv("AZURE_DEPLOYMENT_NAME"), # deployment name
  messages=[
      {"role": "system", "content": "You are a very accurate calculator. You output only the result of the calculation."},
      {"role": "user", "content": "1 + 5 = "}],
  # temperature=0, # gpt-5 doesn't accept this parameter
  metadata={"someMetadataKey": "someValue"},
)
```