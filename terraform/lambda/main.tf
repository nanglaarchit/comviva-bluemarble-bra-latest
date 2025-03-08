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

data "aws_caller_identity" "comviva-bluemarble-bra" {}
data "aws_partition" "comviva-bluemarble-bra" {}
data "aws_region" "comviva-bluemarble-bra" {}
locals {
  prefix = "${var.namespace}-${var.environment}"
  account_id = data.aws_caller_identity.comviva-bluemarble-bra.account_id
  partition  = data.aws_partition.comviva-bluemarble-bra.partition
  region     = data.aws_region.comviva-bluemarble-bra.name
}


# S3 Bucket Data
data "aws_s3_bucket" "bucket_arn" {
  bucket = var.s3_bucket_name
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_bedrock_access" {
  name       = "${local.prefix}-lambda-bedrock-access"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

# IAM Policy for Lambda S3 Access
resource "aws_iam_policy" "lambda_s3_access" {
  name        = "${local.prefix}-lambda-s3-access"
  description = "Allow Lambda to read/write S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${data.aws_s3_bucket.bucket_arn.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = data.aws_s3_bucket.bucket_arn.arn
      }
    ]
  })
}

# Attach IAM Policies to Lambda Role
resource "aws_iam_policy_attachment" "lambda_s3_attachment" {
  name       = "${local.prefix}-lambda-s3-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "${local.prefix}-lambda-basic-execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Get Docker Image URI from SSM
data "aws_ssm_parameter" "docker_image_uri" {
  name = "/comviva/bra-docker-image-uri"
}

# Lambda Function
resource "aws_lambda_function" "container_lambda" {
  function_name    = "${local.prefix}-lambda-function"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = sha1(data.aws_ssm_parameter.docker_image_uri.value)
  package_type     = "Image"
  image_uri        = data.aws_ssm_parameter.docker_image_uri.value
  timeout          = 120
  memory_size      = 2048
  ephemeral_storage {
    size = 2048
  }
  environment {
    variables = {
      data_bucket             = "comviva-dev-data-bucket-comviva-bra"
      data_bucket_folder_name = "demo-1"
    }
  }
}

resource "aws_lambda_permission" "bedrock_invoke" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.container_lambda.function_name
  principal     = "bedrock.amazonaws.com"
  #   source_arn    = "arn:aws:bedrock:us-west-2:804295906245:agent/*"
  source_arn = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"
}
