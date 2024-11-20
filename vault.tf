#Get Installer Passwords
data "vault_kv_secret_v2" "tfe_config" {
  mount = "/kvv2"
  name = "tfe_config"
}
locals {
  db_password           = data.vault_kv_secret_v2.tfe_config.data["tfe_database_password"]
  redis_password        = data.vault_kv_secret_v2.tfe_config.data["tfe_redis_password"]
  tfe_license           = data.vault_kv_secret_v2.tfe_config.data["tfe_license"]
  encryption_password   = data.vault_kv_secret_v2.tfe_config.data["tfe_encryption"]
}
#Request TFE services certficate
resource "vault_pki_secret_backend_cert" "tfe_tls" {
  backend = "pki_int_milabs_co"
  name = "milabs-dot-co"
  common_name = "terraform.milabs.co"
  ttl = "90d"
}