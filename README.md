# Deploy Langfuse(v3) on Azure Container Apps

[Langfuse](https://langfuse.com/self-hosting)をAzure Container Apps上でホスティングするためのbicep定義置き場

- [step0](step0) ほぼそのまま
  - [公式repoのdocker-compose.yml](https://github.com/langfuse/langfuse/blob/4c2c3d21c7d6a253e026cde0b61c0369cfb7208b/docker-compose.yml)をそのままContainer Appsのbicepに書き換え
  - この段階ではボリュームが永続化できずコンテナ立ち上げのたびにデータが消える
  - 簡単にLangfuseの動作を確認するだけならこれでもたぶんOK
- [step1](step1) ロギング+ネットワーク関連の設定を強化
  - (TODO) step0 +
    - ハードコードされている機密情報系を分離してデプロイ時に指定できるようパラメータ化
    - ログ保存用にLog Analyticsを追加
    - step2以降のデータストア分離に向けてVNet統合
    - インターネット経由のアクセスを制限
- step2(TODO): step1 + ストレージ(minio)を分離、Azure Blob Storageに移行
  - イベントが永続化される
- step3(TODO): step2 + PostgreSQLを分離、Azure Database for PostgreSQL(flexible server)に移行
  - トランザクションデータが永続化される
- step4(TODO): step3 + ClickHouseのデータをAzure Blob Storageで永続化
  - 監視データが永続化される
  - ここまでくれば割と安心して使えるはず...  
