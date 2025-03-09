# Terraform Configuration for AWS S3 Bucket

## Overview

This Terraform project provisions an AWS S3 bucket using modular infrastructure. The Terraform state is managed using an S3 backend with DynamoDB for state locking.

## Prerequisites

- Terraform >= 1.4
- AWS CLI configured with appropriate credentials
- S3 backend for storing Terraform state
- DynamoDB table for state locking (recommended)

## Files Overview

- `main.tf`: Defines the Terraform configuration, including provider, backend, modules, and resources.
- `variables.tf`: Declares input variables for customization.
- `tfvars/dev.tfvars`: Defines environment-specific variables for the development environment.
- `backend/config.dev.hcl`: Contains the backend configuration for storing the Terraform state in an S3 bucket.
- `demo-1/`: Directory containing files to be uploaded to S3.

## Backend Configuration

The backend configuration is stored in `backend/config.dev.hcl` and includes:

```hcl
region         = "us-west-2"
key            = "comviva-s3/terraform.tfstate"
bucket         = "comviva-backend-state-latest"
dynamodb_table = "comviva-state-lock-latest"
encrypt        = true
```

Ensure that `comviva-backend-state-latest` exists as an S3 bucket and `comviva-state-lock-latest` is created as a DynamoDB table.

## Variables

| Variable    | Description                        | Default   |
| ----------- | ---------------------------------- | --------- |
| aws_region  | AWS Region for deployment          | us-west-2 |
| namespace   | Project namespace prefix           | None      |
| environment | Deployment environment (dev, prod) | None      |
| name        | S3 Bucket Name                     | None      |
| acl         | Access control list setting        | None      |

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

## Notes

- Ensure that the AWS credentials are correctly configured before running Terraform commands.
- Modify the backend configuration as needed to match your S3 bucket details.
- Using a DynamoDB table (`comviva-state-lock-latest`) is recommended for state locking to prevent conflicts in multi-user environments.
- The `demo-1/` directory should contain the necessary files before running Terraform to avoid errors.
