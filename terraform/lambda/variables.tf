variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "namespace" {
  description = "Project namespace prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

