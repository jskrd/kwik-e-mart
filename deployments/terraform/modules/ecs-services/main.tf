resource "aws_ecs_service" "web" {
  name            = "web"
  cluster         = var.ecs_cluster_arn
  task_definition = var.web_task_definition_arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.web_target_group_arn
    container_name   = "web"
    container_port   = 8000
  }
}
