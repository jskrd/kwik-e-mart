output "web_target_group_arn" {
  value = {
    for branch in var.banches : branch => aws_lb_target_group.web[branch].arn
  }
}
