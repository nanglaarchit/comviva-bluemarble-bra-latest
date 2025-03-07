variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. refarch"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region"
}

variable "name" {
  type        = string
  description = "Bucket Name"
}

variable "acl" {
  type        = string
  description = "ACL value"
}