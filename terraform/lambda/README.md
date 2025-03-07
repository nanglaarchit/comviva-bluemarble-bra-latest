# Terraform Configuration for AWS Lambda with S3 Access

## Overview

This Terraform project provisions an AWS Lambda function that runs a containerized application. The Lambda function retrieves its Docker image from AWS Systems Manager (SSM) and has the necessary IAM roles and policies to access Amazon S3 and AWS Bedrock. The Terraform state is managed using an S3 backend with DynamoDB for state locking.

## Prerequisites

- Terraform >= 1.4
- AWS CLI configured with appropriate credentials
- An existing S3 bucket for storage
- Docker image URI stored in AWS Systems Manager Parameter Store
- S3 backend for storing Terraform state
- DynamoDB table for state locking (recommended)

## Files Overview

- `main.tf`: Defines the Terraform configuration, including provider, backend, IAM roles, Lambda function, and S3 bucket access.
- `variables.tf`: Declares input variables for customization.
- `tfvars/dev.tfvars`: Defines environment-specific variables for the development environment.
- `backend/config.dev.hcl`: Contains the backend configuration for storing the Terraform state in an S3 bucket.

## Backend Configuration

The backend configuration is stored in `backend/config.dev.hcl` and includes:

```hcl
region         = "us-west-2"
key            = "comviva-lambda/terraform.tfstate"
bucket         = "comviva-backend-state-latest"
dynamodb_table = "comviva-state-lock-latest"
encrypt        = true
```

Ensure that `comviva-backend-state-latest` exists as an S3 bucket and `comviva-state-lock-latest` is created as a DynamoDB table.

## Variables

| Variable       | Description                              | Default                 |
| -------------- | ---------------------------------------- | ----------------------- |
| aws_region     | AWS Region for deployment                | us-west-2               |
| namespace      | Project namespace prefix                 | None                    |
| environment    | Deployment environment (dev, prod)       | None                    |
| s3_bucket_name | Name of the S3 bucket accessed by Lambda | None (must be provided) |

## Deployment Steps

1. **Initialize Terraform with the backend configuration:**
   ```sh
   terraform init -backend-config=backend/config.dev.hcl
   ```
2. **Plan the deployment:**
   ```sh
   terraform plan -var-file=tfvars/dev.tfvars
   ```
3. **Apply the deployment:**
   ```sh
   terraform apply -var-file=tfvars/dev.tfvars -auto-approve
   ```
4. **Destroy the infrastructure (if needed):**
   ```sh
   terraform destroy -var-file=tfvars/dev.tfvars -auto-approve
   ```

## Resources Created

- **IAM Role & Policies**: A Lambda execution role with policies granting access to S3 and AWS Bedrock.
- **AWS Lambda Function**:
  - Uses a containerized image from AWS SSM Parameter Store.
  - Has IAM permissions for interacting with S3 and Bedrock.
  - Configured with a timeout of 120 seconds and 2048 MB of memory.
- **S3 Access**: Lambda can read/write objects in the specified S3 bucket.

## Notes

- Ensure that the AWS credentials are correctly configured before running Terraform commands.
- Modify the backend configuration as needed to match your S3 bucket details.
- Using a DynamoDB table (`comviva-state-lock-latest`) is recommended for state locking to prevent conflicts in multi-user environments.
- The Docker image URI must be stored in AWS Systems Manager Parameter Store (`/comviva/docker-image-latest-uri`).
