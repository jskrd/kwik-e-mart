variable "project_name" {
  description = "Name of the project (e.g., kwik-e-mart)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, preview)"
  type        = string
  validation {
    condition     = contains(["production", "preview"], var.environment)
    error_message = "Environment must be either 'production' or 'preview'"
  }
}
