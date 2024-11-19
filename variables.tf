#Compute
variable "ami" {
  description = "EC2 image to use"
}
variable "region" {
  description = "AWS Region to deploy to"
  default = "us-east-1"
}
variable "name" {
  description = "Name of EC2 Instance"
}
variable "instance_type" {
  description = "Instance Type of EC2 instance"
  default = "t2.medium"
}
variable "env" {
  description = "Environment tag you're deploying into"
  default = "Development"
}
variable "owner" {
  description = "Owner Tag of TFE deployment"
  default = "TFE Team"
}
variable "lb_name" {
  description = "Name of existing Load Balancer to Use for TFE front end"
}
variable "public_ca_key" {
  description = "public key"
}

# DB variables
variable "db_username" {
  description = "RDS Database username"
}
variable "db_name" {
  description = "RDS database name"
}

#TFE variables
variable "tfe_version" {
  default = "v202410-1"
}

variable "TFE_HOSTNAME" {
  default = "terraform.milabs.co"
}
variable "TFE_IACT_SUBNETS" {
  default = "0.0.0.0/0"
}
#vault variables
variable "vault_addr" {
  description = "url of vault instance"
}
variable "vault_namespace" {
  description = "namespace of vault secrets"
}
variable "vault_username" {
  description = "username to log into Vault"
} 
variable "vault_password" {
  description = "vault user password"
  sensitive = true
}

#S3 variables
variable "s3_bucket" {
  description = "Unique S3 bucket name to use for TFE"
}