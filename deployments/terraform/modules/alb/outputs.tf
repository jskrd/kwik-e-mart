output "web_target_group_arn" {
  value = {
    for branch in var.branches : branch => aws_lb_target_group.web[branch].arn
  }
}
