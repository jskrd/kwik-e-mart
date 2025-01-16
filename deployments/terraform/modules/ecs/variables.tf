variable "branches" {
  type = set(string)
}

variable "ecr_repository_url" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_subnet_ids" {
  type = set(string)
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "route53_zone_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "web_target_group_arn" {
  type = map(string)
}
