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

# Define Prefix for Naming Convention
locals {
  prefix      = "${var.namespace}-${var.environment}"
  bucket_name = split(":", module.s3.bucket_arn)[5]
}

# Tagging Module
module "tags" {
  source      = "sourcefuse/arc-tags/aws"
  version     = "1.2.3"
  environment = var.environment
  project     = var.namespace

  extra_tags = {
    RepoName = "${local.prefix}-terraform-aws-arc-s3"
  }
}

# S3 Bucket Module with Prefixed Name
module "s3" {
  source = "sourcefuse/arc-s3/aws"
  name   = "${local.prefix}-${var.name}"  # Prefixing the bucket name
  acl    = var.acl
  tags   = module.tags.tags
}

# Upload Expressions Folder to S3
resource "aws_s3_object" "expressions_folder" {
  for_each     = fileset("${path.module}/demo-1", "**")
  bucket       = local.bucket_name
  key          = "demo-1/${each.value}"
  source       = "${path.module}/demo-1/${each.value}"
  content_type = "application/octet-stream"
  depends_on   = [module.s3]
}