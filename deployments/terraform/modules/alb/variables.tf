variable "branches" {
  type = set(string)
}

variable "certificate_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "public_subnet_ids" {
  type = set(string)
}

variable "route53_zone_name" {
  type = string
}

variable "vpc_id" {
  type = string
}
