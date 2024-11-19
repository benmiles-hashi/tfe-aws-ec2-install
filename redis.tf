/* resource "aws_elasticache_cluster" "tfe_redis" {
  cluster_id           = "tfe-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnets.name
  security_group_ids   = [aws_security_group.tfe-ec2-redis-sg.id]
}*/
resource "aws_elasticache_replication_group" "tfe_redis_rg" {
  automatic_failover_enabled  = false
  multi_az_enabled            = false
  engine                      = "redis"
  replication_group_id        = "tfe-rep-group-1"
  description                 = "TFE Redis Server"
  node_type                   = var.redis_instance_type
  num_cache_clusters          = 1
  parameter_group_name        = "default.redis7"
  engine_version              = "7.1"
  port                        = 6379
  transit_encryption_enabled = true
  #user_group_ids = [aws_elasticache_user_group.tfe_user_group.id]
  subnet_group_name = aws_elasticache_subnet_group.redis_subnets.name
  security_group_ids = [aws_security_group.tfe-ec2-redis-sg.id]
  apply_immediately = true
  auth_token = local.redis_password
}
resource "aws_elasticache_subnet_group" "redis_subnets" {
   name = "tfe-ec2-redis-subnets"
   subnet_ids = data.aws_subnets.private.ids
}
resource "aws_elasticache_user" "tfe_user" {
  user_id       = var.redis_username
  user_name     = var.redis_username
  access_string = "on ~* +@all"
  engine        = "REDIS"
  authentication_mode {
    type      = "password"
    passwords = [local.redis_password]
  }
}
data "aws_elasticache_user" "default_user" {
  user_id       = "default"
}
 resource "aws_elasticache_user_group" "tfe_user_group" {
  engine        = "REDIS"
  user_group_id = "tfeusergroup"
  user_ids      = [data.aws_elasticache_user.default_user.user_id, aws_elasticache_user.tfe_user.user_id]
}
/*
resource "aws_elasticache_user_group_association" "tfe_user_group_ass" {
  user_group_id = aws_elasticache_user_group.tfe_user_group.user_group_id
  user_id       = aws_elasticache_user.tfe_user.user_id
} */