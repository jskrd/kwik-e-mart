variable "availability_zones" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "project_octet" {
  type        = number
  description = "Base octet for project VPC CIDR (should be unique per project, production will use base+1)"

  validation {
    condition     = var.project_octet >= 0 && var.project_octet <= 254 && var.project_octet % 2 == 0
    error_message = "Project octet must be an even number between 0 and 254 to allow for production offset."
  }
}
