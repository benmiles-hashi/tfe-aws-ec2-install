#!/bin/bash

sudo yum update -y
sudo yum install docker wget postgresql15 redis6 -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

EC2_TOKEN=$(curl --noproxy -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
VM_PRIVATE_IP=$(curl --noproxy -sS -H "X-aws-ec2-metadata-token: $EC2_TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

sudo mkdir -p /tfe/certs

cat > /tfe/tfe-compose.yaml <<EOF
---
name: terraform-enterprise
services:
  tfe:
    image: images.releases.hashicorp.com/hashicorp/terraform-enterprise:${tfe_version}
    environment:
      TFE_LICENSE: "${tfe_license}"
      TFE_HOSTNAME: "${TFE_HOSTNAME}"
      TFE_RUN_PIPELINE_DOCKER_EXTRA_HOSTS: ${TFE_HOSTNAME}:$VM_PRIVATE_IP
      TFE_ENCRYPTION_PASSWORD: "${TFE_ENCRYPTION_PASSWORD}"
      TFE_OPERATIONAL_MODE: "active-active"
      TFE_DISK_CACHE_VOLUME_NAME: "terraform-enterprise_terraform-enterprise-cache"
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
      #TFE_REDIS_USER: "${TFE_REDIS_USER}"
      TFE_REDIS_PASSWORD: "${TFE_REDIS_PASSWORD}"
      TFE_REDIS_USE_TLS: "true"
      TFE_REDIS_USE_AUTH: "true"

      TFE_VAULT_CLUSTER_ADDRESS: "https://$VM_PRIVATE_IP:8201"

    cap_add:
      - IPC_LOCK
    extra_hosts:
      - ${TFE_HOSTNAME}:$VM_PRIVATE_IP
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
EOF

echo "${cert}" | sudo tee /tfe/certs/cert.pem
echo "${key}" | sudo tee /tfe/certs/key.pem
echo "${bundle}" | sudo tee /tfe/certs/bundle.pem

su ec2-user -c 'echo "${tfe_license}" |  docker login --username terraform images.releases.hashicorp.com --password-stdin'
su ec2-user -c 'docker pull images.releases.hashicorp.com/hashicorp/terraform-enterprise:${tfe_version}'
su ec2-user -c 'docker-compose -f /tfe/tfe-compose.yaml up -d'