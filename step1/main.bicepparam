using './main.bicep'

param telemetryEnabled = readEnvironmentVariable('TELEMETRY_ENABLED', 'true')
param langfuseEnableExperimentalFeatures = readEnvironmentVariable('LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES', 'true')
param clickhouseMigrationUrl = readEnvironmentVariable('CLICKHOUSE_MIGRATION_URL', 'clickhouse://localhost:9000')
param clickhouseUrl = readEnvironmentVariable('CLICKHOUSE_URL', 'http://localhost:8123')
param clickhouseUser = readEnvironmentVariable('CLICKHOUSE_USER', 'clickhouse')
param clickhousePassword = readEnvironmentVariable('CLICKHOUSE_PASSWORD', 'clickhouse')
param clickhouseClusterEnabled = readEnvironmentVariable('CLICKHOUSE_CLUSTER_ENABLED', 'false')
param langfuseUseAzureBlob = readEnvironmentVariable('LANGFUSE_USE_AZURE_BLOB', 'false')
param langfuseS3EventUploadBucket = readEnvironmentVariable('LANGFUSE_S3_EVENT_UPLOAD_BUCKET', 'langfuse')
param langfuseS3EventUploadRegion = readEnvironmentVariable('LANGFUSE_S3_EVENT_UPLOAD_REGION', 'auto')
param langfuseS3EventUploadAccessKeyId = readEnvironmentVariable('LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID', 'minio')
param langfuseS3EventUploadSecretAccessKey = readEnvironmentVariable(
  'LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY',
  'miniosecret'
)
param langfuseS3EventUploadEndpoint = readEnvironmentVariable(
  'LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT',
  // 'http://localhost:9000' 
  'http://localhost:9090' // ACAではminioとclickhouseでコンテナのポートが衝突してしまうので、9000→9090, 9001→9091に変更
)
param langfuseS3EventUploadForcePathStyle = readEnvironmentVariable('LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE', 'true')
param langfuseS3EventUploadPrefix = readEnvironmentVariable('LANGFUSE_S3_EVENT_UPLOAD_PREFIX', 'events/')
param langfuseS3MediaUploadBucket = readEnvironmentVariable('LANGFUSE_S3_MEDIA_UPLOAD_BUCKET', 'langfuse')
param langfuseS3MediaUploadRegion = readEnvironmentVariable('LANGFUSE_S3_MEDIA_UPLOAD_REGION', 'auto')
param langfuseS3MediaUploadAccessKeyId = readEnvironmentVariable('LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID', 'minio')
param langfuseS3MediaUploadSecretAccessKey = readEnvironmentVariable(
  'LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY',
  'miniosecret'
)
param langfuseS3MediaUploadEndpoint = readEnvironmentVariable(
  'LANGFUSE_S3_MEDIA_UPLOAD_ENDPOINT',
  // 'http://localhost:9000' 
  'http://localhost:9090' // ACAではminioとclickhouseでコンテナのポートが衝突してしまうので、9000→9090, 9001→9091に変更
)
param langfuseS3MediaUploadForcePathStyle = readEnvironmentVariable('LANGFUSE_S3_MEDIA_UPLOAD_FORCE_PATH_STYLE', 'true')
param langfuseS3MediaUploadPrefix = readEnvironmentVariable('LANGFUSE_S3_MEDIA_UPLOAD_PREFIX', 'media/')
param langfuseS3BatchExportEnabled = readEnvironmentVariable('LANGFUSE_S3_BATCH_EXPORT_ENABLED', 'false')
param langfuseS3BatchExportBucket = readEnvironmentVariable('LANGFUSE_S3_BATCH_EXPORT_BUCKET', 'langfuse')
param langfuseS3BatchExportPrefix = readEnvironmentVariable('LANGFUSE_S3_BATCH_EXPORT_PREFIX', 'exports/')
param langfuseS3BatchExportRegion = readEnvironmentVariable('LANGFUSE_S3_BATCH_EXPORT_REGION', 'auto')
param langfuseS3BatchExportEndpoint = readEnvironmentVariable(
  'LANGFUSE_S3_BATCH_EXPORT_ENDPOINT',
  // 'http://localhost:9000' 
  'http://localhost:9090' // ACAではminioとclickhouseでコンテナのポートが衝突してしまうので、9000→9090, 9001→9091に変更
)
param langfuseS3BatchExportExternalEndpoint = readEnvironmentVariable(
  'LANGFUSE_S3_BATCH_EXPORT_EXTERNAL_ENDPOINT',
  // 'http://localhost:9000' 
  'http://localhost:9090' // ACAではminioとclickhouseでコンテナのポートが衝突してしまうので、9000→9090, 9001→9091に変更
)
param langfuseS3BatchExportAccessKeyId = readEnvironmentVariable('LANGFUSE_S3_BATCH_EXPORT_ACCESS_KEY_ID', 'minio')
param langfuseS3BatchExportSecretAccessKey = readEnvironmentVariable(
  'LANGFUSE_S3_BATCH_EXPORT_SECRET_ACCESS_KEY',
  'miniosecret'
)
param langfuseS3BatchExportForcePathStyle = readEnvironmentVariable('LANGFUSE_S3_BATCH_EXPORT_FORCE_PATH_STYLE', 'true')
param langfuseIngestionQueueDelayMs = readEnvironmentVariable('LANGFUSE_INGESTION_QUEUE_DELAY_MS', '')
param langfuseIngestionClickhouseWriteIntervalMs = readEnvironmentVariable(
  'LANGFUSE_INGESTION_CLICKHOUSE_WRITE_INTERVAL_MS',
  ''
)
param redisHost = readEnvironmentVariable('REDIS_HOST', 'localhost')
param redisPort = readEnvironmentVariable('REDIS_PORT', '6379')
param redisAuth = readEnvironmentVariable('REDIS_AUTH', 'myredissecret')
param redisTlsEnabled = readEnvironmentVariable('REDIS_TLS_ENABLED', 'false')
param redisTlsCa = readEnvironmentVariable('REDIS_TLS_CA', '/certs/ca.crt')
param redisTlsCert = readEnvironmentVariable('REDIS_TLS_CERT', '/certs/redis.crt')
param redisTlsKey = readEnvironmentVariable('REDIS_TLS_KEY', '/certs/redis.key')
param emailFromAddress = readEnvironmentVariable('EMAIL_FROM_ADDRESS', '')
param smtpConnectionUrl = readEnvironmentVariable('SMTP_CONNECTION_URL', '')
param langfuseInitOrgId = readEnvironmentVariable('LANGFUSE_INIT_ORG_ID', '')
param langfuseInitOrgName = readEnvironmentVariable('LANGFUSE_INIT_ORG_NAME', '')
param langfuseInitProjectId = readEnvironmentVariable('LANGFUSE_INIT_PROJECT_ID', '')
param langfuseInitProjectName = readEnvironmentVariable('LANGFUSE_INIT_PROJECT_NAME', '')
param langfuseInitProjectPublicKey = readEnvironmentVariable('LANGFUSE_INIT_PROJECT_PUBLIC_KEY', '')
param langfuseInitProjectSecretKey = readEnvironmentVariable('LANGFUSE_INIT_PROJECT_SECRET_KEY', '')
param langfuseInitUserEmail = readEnvironmentVariable('LANGFUSE_INIT_USER_EMAIL', '')
param langfuseInitUserName = readEnvironmentVariable('LANGFUSE_INIT_USER_NAME', '')
param langfuseInitUserPassword = readEnvironmentVariable('LANGFUSE_INIT_USER_PASSWORD', '')
param postgresUser = readEnvironmentVariable('POSTGRES_USER', 'postgres')
param postgresDb = readEnvironmentVariable('POSTGRES_DB', 'postgres')
param postgresPassword = readEnvironmentVariable('POSTGRES_PASSWORD', 'postgres')
param langfuseSalt = readEnvironmentVariable('SALT', 'mysalt')
param langfuseEncryptionKey = readEnvironmentVariable(
  'ENCRYPTION_KEY',
  '0000000000000000000000000000000000000000000000000000000000000000'
)
param langfuseNextAuthSecret = readEnvironmentVariable('NEXTAUTH_SECRET', 'mysecret')
param minioRootPassword = readEnvironmentVariable('MINIO_ROOT_PASSWORD', 'miniosecret')
