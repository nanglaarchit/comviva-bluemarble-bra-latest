################################################################
## shared
################################################################
variable "region" {
  description = "Region the resources will live in."
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Name of the Dynamo DB lock table."
  type        = string
  default     = "dev"
}

################################################################
## s3
################################################################
variable "bucket_name" {
  description = "Name of the bucket."
  type        = string
}

################################################################
## dynamodb
################################################################
variable "dynamodb_name" {
  description = "Name of the Dynamo DB lock table."
  type        = string
}
