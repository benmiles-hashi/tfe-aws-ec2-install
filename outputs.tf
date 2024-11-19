output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.tfe-ec2-postgres.address
  sensitive   = false
}
output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.tfe-ec2-postgres.port
  sensitive   = false
}
output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.tfe-ec2-postgres.username
  sensitive   = false
}
output "redis_endpoint" {
    description = "Redis Endpoint Address"
    value = "${aws_elasticache_replication_group.tfe_redis_rg.primary_endpoint_address}:${aws_elasticache_replication_group.tfe_redis_rg.port}"
    #value = "${aws_elasticache_cluster.tfe_redis.cache_nodes[0].address}:${aws_elasticache_cluster.tfe_redis.cache_nodes[0].port}"
}
output "tfe_ec2_pubicip" {
    description = "Public IP address of EC2 Instance"
    value = aws_instance.tfe-ec2.public_ip
}
output "tfe_url" {
  description = "FQDN of LB to TFE Server"
  value = "https://${var.TFE_HOSTNAME}"
}

