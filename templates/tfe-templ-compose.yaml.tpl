---
name: terraform-enterprise
services:
  tfe:
    image: images.releases.hashicorp.com/hashicorp/terraform-enterprise:${tfe_version}
    environment:
      TFE_LICENSE: "${tfe_license}"
      TFE_HOSTNAME: "${TFE_HOSTNAME}"
      TFE_ENCRYPTION_PASSWORD: "${TFE_ENCRYPTION_PASSWORD}"
      TFE_OPERATIONAL_MODE: "active-active"
      TFE_DISK_CACHE_VOLUME_NAME: "tfe_terraform-enterprise-cache"
      TFE_TLS_CERT_FILE: "/etc/ssl/private/terraform-enterprise/cert.pem"
      TFE_TLS_KEY_FILE: "/etc/ssl/private/terraform-enterprise/key.pem"
      TFE_TLS_CA_BUNDLE_FILE: "/etc/ssl/private/terraform-enterprise/bundle.pem"
      TFE_IACT_SUBNETS: "${TFE_IACT_SUBNETS}"

      # Database settings. See the configuration reference for more settings.
      TFE_DATABASE_USER: "${TFE_DATABASE_USER}"
      TFE_DATABASE_PASSWORD: "${TFE_DATABASE_PASSWORD}"
      TFE_DATABASE_HOST: "${TFE_DATABASE_HOST}"
      TFE_DATABASE_NAME: "${TFE_DATABASE_USER}"

      # Object storage settings. See the configuration reference for more settings.
      TFE_OBJECT_STORAGE_TYPE: "s3"
      TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE: "true"
      TFE_OBJECT_STORAGE_S3_REGION: "${TFE_OBJECT_STORAGE_S3_REGION}"
      TFE_OBJECT_STORAGE_S3_BUCKET: "${TFE_OBJECT_STORAGE_S3_BUCKET}"

      TFE_REDIS_HOST: "${TFE_REDIS_HOST}"
      TFE_REDIS_USER: "${TFE_REDIS_USER}"
      TFE_REDIS_PASSWORD: "${TFE_REDIS_PASSWORD}"
      TFE_REDIS_USE_TLS: "false"
      TFE_REDIS_USE_AUTH: "false"

      TFE_VAULT_CLUSTER_ADDRESS: "https://127.0.0.1:8201"

    cap_add:
      - IPC_LOCK
    read_only: true
    tmpfs:
      - /tmp:mode=01777
      - /run
      - /var/log/terraform-enterprise
    ports:
      - "80:80"
      - "443:443"
      - "8201:8201"
    volumes:
      - type: bind
        source: /var/run/docker.sock
        target: /run/docker.sock
      - type: bind
        source: ./certs
        target: /etc/ssl/private/terraform-enterprise
      - type: volume
        source: terraform-enterprise-cache
        target: /var/cache/tfe-task-worker/terraform
volumes:
  terraform-enterprise-cache: