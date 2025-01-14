resource "aws_route53_zone" "main" {
  name = "${var.project_name}.${var.base_domain}"
}
