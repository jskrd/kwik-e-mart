resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  cluster_name = aws_ecs_cluster.main.name

  default_capacity_provider_strategy {
    capacity_provider = var.environment == "production" ? "FARGATE" : "FARGATE_SPOT"
    weight            = 100
    base              = var.environment == "production" ? 1 : 0
  }
}
