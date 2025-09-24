output "target_group_arn" {
  value = aws_lb_listener.platform.default_action[0].target_group_arn
}
