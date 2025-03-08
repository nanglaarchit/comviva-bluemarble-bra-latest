terraform {
  required_version = ">= 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

locals {
  prefix = "${var.namespace}-${var.environment}"
}

# ECR Repository
resource "aws_ecr_repository" "my_repo" {
  name                 = "${local.prefix}-bluemarble-bedrock-bra"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "comviva-bluemarble"
    Env     = var.environment
  }
}
