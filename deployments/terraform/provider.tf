resource "aws_s3_bucket" "terraform_state" {
  bucket = "kwik-e-mart-terraform-state"
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  attribute {
    name = "LockID"
    type = "S"
  }
  hash_key     = "LockID"
  name         = "kwik-e-mart-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }

  backend "s3" {
    bucket         = "kwik-e-mart-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "kwik-e-mart-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}
