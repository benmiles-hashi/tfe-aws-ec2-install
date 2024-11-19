data "aws_vpc" "main" {
  default = true
}
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}
resource "aws_security_group" "allow_ssh" {
  name        = "tfe_ec2_allow_ssh_http-https${random_id.id.hex}"
  description = "Allow SSH and HTTP/S inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "tfe_ec2_allow_ssh_http_https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#Redis
resource "aws_security_group" "tfe-ec2-redis-sg" {
  name        = "tfe_ec2_allow_redis-${random_id.id.hex}"
  description = "Allow Redis inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "tfe_ec2_allow_redis"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_redis" {
  security_group_id = aws_security_group.tfe-ec2-redis-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}
resource "aws_vpc_security_group_egress_rule" "redis_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.tfe-ec2-redis-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
