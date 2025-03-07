# Reference Architecture DevOps Infrastructure: Bootstrap

## Overview

AWS bootstrap for the DevOps Reference Architecture Infrastructure. This module sets up resources for managing the Terraform Backend State. It provisions an S3 bucket for storing Terraform state files and a DynamoDB table for state locking, ensuring consistency and preventing conflicts in multi-user environments.

### Steps to Setup Backend State

1. **Comment out** the `backend "s3" {}` block in `main.tf`.
2. Initialize Terraform without backend:
   ```sh
   terraform init -backend-config=backend/config.dev.hcl
   ```
3. Apply Terraform to create necessary resources:
   ```sh
   terraform apply -var-file=tfvars/dev.tfvars
   ```
4. **Uncomment** the `backend "s3" {}` block in `main.tf`.
5. Reinitialize Terraform to migrate state into S3:
   ```sh
   terraform init -backend-config=backend/config.dev.hcl
   ```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.4  |
| aws       | >= 4.0  |

## Modules

| Name      | Source                       | Version |
| --------- | ---------------------------- | ------- |
| bootstrap | sourcefuse/arc-bootstrap/aws | 1.1.7   |
| tags      | sourcefuse/arc-tags/aws      | 1.2.2   |

## Inputs

| Name          | Description                        | Type   | Default     | Required |
| ------------- | ---------------------------------- | ------ | ----------- | -------- |
| bucket_name   | Name of the bucket.                | string | n/a         | yes      |
| dynamodb_name | Name of the DynamoDB lock table.   | string | n/a         | yes      |
| environment   | Deployment environment (dev/prod). | string | "dev"       | no       |
| region        | AWS Region.                        | string | "us-west-2" | no       |
