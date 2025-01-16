locals {
  dummy_environment = [
    {
      name  = "APP_KEY"
      value = "base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    },
    {
      name  = "LOG_STACK",
      value = "stderr"
    },
    {
      name  = "SESSION_DRIVER"
      value = "array"
    }
  ]
}

resource "aws_cloudwatch_log_group" "main" {
  for_each = var.branches

  name              = "/ecs/${var.project_name}-${var.environment}-${each.value}"
  retention_in_days = 7
}

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

resource "aws_ecs_task_definition" "web" {
  for_each = var.branches

  family = "${var.project_name}-${each.value}-web"
  container_definitions = jsonencode([
    {
      name  = "web"
      image = "${var.ecr_repository_url}:${each.value}"
      portMappings = [
        {
          containerPort = 8000,
          protocol      = "tcp"
        }
      ]
      environment = local.dummy_environment
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-${each.value}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "web"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.environment == "production" ? 512 : 256
  memory                   = var.environment == "production" ? 1024 : 512
  execution_role_arn       = var.ecs_task_execution_role_arn
}

resource "aws_ecs_task_definition" "worker" {
  for_each = var.branches

  family = "${var.project_name}-${each.value}-worker"
  container_definitions = jsonencode([
    {
      name        = "worker"
      image       = "${var.ecr_repository_url}:${each.value}"
      command     = ["php", "artisan", "queue:work"]
      environment = local.dummy_environment
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-${each.value}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "worker"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.environment == "production" ? 512 : 256
  memory                   = var.environment == "production" ? 1024 : 512
  execution_role_arn       = var.ecs_task_execution_role_arn
}

resource "aws_ecs_task_definition" "scheduler" {
  for_each = var.branches

  family = "${var.project_name}-${each.value}-scheduler"
  container_definitions = jsonencode([
    {
      name        = "scheduler"
      image       = "${var.ecr_repository_url}:${each.value}"
      command     = ["php", "artisan", "schedule:work"]
      environment = local.dummy_environment
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-${each.value}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "scheduler"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${var.project_name}-${var.environment}-ecs-tasks"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ecs_tasks.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8000
  ip_protocol = "tcp"
  to_port     = 8000
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ecs_tasks.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_ecs_service" "web" {
  for_each = var.branches

  name            = "${var.project_name}-${each.value}-web"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.web[each.value].arn
  desired_count   = var.environment == "production" ? 3 : 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  load_balancer {
    target_group_arn = var.web_target_group_arn[each.value]
    container_name   = "web"
    container_port   = 8000
  }
}

resource "aws_ecs_service" "worker" {
  for_each = var.branches

  name            = "${var.project_name}-${each.value}-worker"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.worker[each.value].arn
  desired_count   = var.environment == "production" ? 3 : 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}

resource "aws_ecs_service" "scheduler" {
  for_each = var.branches

  name            = "${var.project_name}-${each.value}-scheduler"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.scheduler[each.value].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}
