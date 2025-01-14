resource "aws_ecr_repository" "main" {
  name = "${var.project_name}/app"
}
