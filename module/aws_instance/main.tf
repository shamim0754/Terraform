terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region                      = "ca-central-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    ec2 = "http://localhost:4566"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-00498a47f0a5d4232"
  instance_type = var.instance_type
  for_each = toset(["sandbox_one", "sandbox_two", "sandbox_three"])
  tags = {
    Name = each.value #each.value is same as each.key
  }
}
