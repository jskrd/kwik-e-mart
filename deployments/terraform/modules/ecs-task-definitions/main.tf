resource "aws_ecs_task_definition" "web" {
  family = "${var.project_name}-${var.environment}-web"
  container_definitions = jsonencode([
    {
      name  = "web"
      image = "${var.ecr_repository_url}"
      portMappings = [
        {
          containerPort = 8000,
          protocol      = "tcp"
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.environment == "production" ? 512 : 256
  memory                   = var.environment == "production" ? 1024 : 512
  execution_role_arn       = var.ecs_task_execution_role_arn
}

resource "aws_ecs_task_definition" "worker" {
  family = "${var.project_name}-${var.environment}-worker"
  container_definitions = jsonencode([
    {
      name    = "worker"
      image   = "${var.ecr_repository_url}"
      command = ["php", "artisan", "queue:work"]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn
}

resource "aws_ecs_task_definition" "scheduler" {
  family = "${var.project_name}-${var.environment}-scheduler"
  container_definitions = jsonencode([
    {
      name    = "scheduler"
      image   = "${var.ecr_repository_url}"
      command = ["php", "artisan", "schedule:work"]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn
}