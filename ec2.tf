locals {
  user_data_args = {
    cert = vault_pki_secret_backend_cert.tfe_tls.certificate
    key = vault_pki_secret_backend_cert.tfe_tls.private_key
    bundle = vault_pki_secret_backend_cert.tfe_tls.ca_chain
    tfe_license = local.tfe_license
    tfe_version = var.tfe_version
    TFE_HOSTNAME = var.TFE_HOSTNAME
    TFE_ENCRYPTION_PASSWORD = local.encryption_password
    TFE_IACT_SUBNETS = var.TFE_IACT_SUBNETS
    TFE_DATABASE_USER = var.db_name
    TFE_DATABASE_PASSWORD = local.db_password
    TFE_DATABASE_HOST = "${aws_db_instance.tfe-ec2-postgres.address}:${aws_db_instance.tfe-ec2-postgres.port}"
    TFE_OBJECT_STORAGE_S3_REGION = var.region
    TFE_OBJECT_STORAGE_S3_BUCKET = aws_s3_bucket.tfe_ec2_s3.bucket
    TFE_REDIS_HOST = "${aws_elasticache_replication_group.tfe_redis_rg.primary_endpoint_address}:${aws_elasticache_replication_group.tfe_redis_rg.port}"
    TFE_REDIS_USER = var.redis_username
    TFE_REDIS_PASSWORD = local.redis_password
  }
  ec2_user_data = templatefile("${path.module}/templates/install_tfe.sh.tpl", local.user_data_args)
}
data "aws_iam_policy" "security_compute_access" {
  name = "SecurityComputeAccess"
}
data "aws_iam_policy_document" "client_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
data "aws_iam_policy" "aws_ec2" {
    name = "AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role" "tfe_ec2_instance_role" {
  name               = "tfe-ec2-instance-role"
  assume_role_policy = data.aws_iam_policy_document.client_policy.json
}
resource "aws_iam_role_policy_attachment" "attach_tfe_ec2_s3_policy" {
  role = aws_iam_role.tfe_ec2_instance_role.name
  policy_arn = aws_iam_policy.tfe_ec2_s3_policy.arn
}
resource "aws_iam_policy" "tfe_ec2_s3_policy" {
  name = "tfe-ec2-s3-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "${aws_s3_bucket.tfe_ec2_s3.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "${aws_s3_bucket.tfe_ec2_s3.arn}/*"
            ]
        }
    ]
  })
}
resource "aws_iam_instance_profile" "instance_profile" {
  name = "tfe_ec2_profile"
  role = aws_iam_role.tfe_ec2_instance_role.name
}
resource "aws_instance" "tfe-ec2" {
  ami                     = var.ami
  instance_type           = var.instance_type
  security_groups         = ["default", aws_security_group.allow_ssh.name]
  key_name                = aws_key_pair.deployer.key_name
  user_data               = base64gzip(local.ec2_user_data)
  iam_instance_profile    = aws_iam_instance_profile.instance_profile.name
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = false
  }
  tags = {
    Name = var.name
    owner = var.owner
    Env   = var.env
  }
  depends_on = [ aws_db_instance.tfe-ec2-postgres, aws_elasticache_replication_group.tfe_redis_rg, aws_s3_bucket.tfe_ec2_s3 ]
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${random_id.id.hex}"
  public_key = var.public_ca_key
}