data "aws_lb" "tfe_lb" {
  name = var.lb_name
}
data "aws_lb_listener" "tfe443" {
  load_balancer_arn = data.aws_lb.tfe_lb.arn
  port              = 443
}
data "aws_lb_listener" "tfe80" {
  load_balancer_arn = data.aws_lb.tfe_lb.arn
  port              = 80
}
#Add EC2 to load balaner target groups
resource "aws_lb_target_group_attachment" "tfe_tg_443" {
  target_group_arn = tolist(data.aws_lb_listener.tfe443.default_action[0].forward[0].target_group)[0].arn
  target_id        = aws_instance.tfe-ec2.private_ip
  port             = 443
}
resource "aws_lb_target_group_attachment" "tfe_tg_80" {
  target_group_arn = tolist(data.aws_lb_listener.tfe80.default_action[0].forward[0].target_group)[0].arn
  target_id        = aws_instance.tfe-ec2.private_ip
  port             = 80
} 