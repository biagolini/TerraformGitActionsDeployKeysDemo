# Specify the required Terraform version and configure the remote state backend
terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "tutorial-terraform-tfstate"   # S3 bucket used for remote state storage
    key            = "terraform/dev/lambda.tfstate" # Path within the bucket to store the state
    region         = "us-east-1"                    # AWS region of the state bucket
    dynamodb_table = "terraform-lock-table"         # DynamoDB table used for locking
    encrypt        = true                           # Enable encryption for the state bucket
  }
}

# AWS provider configuration with common default tags
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      environment = "Dev"
      project     = "git-actions-demo"
    }
  }
}
