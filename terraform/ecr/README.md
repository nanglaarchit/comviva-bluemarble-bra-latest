# Terraform Configuration for AWS ECR Repository

## Overview

This Terraform project provisions an AWS Elastic Container Registry (ECR) repository to store container images. The infrastructure follows a modular approach using variables for flexibility in different environments. The Terraform state is managed using an S3 backend.

## Prerequisites

- Terraform >= 1.4
- AWS CLI configured with appropriate credentials
- S3 backend for storing Terraform state
- DynamoDB table for state locking (optional but recommended)

## Files Overview

├── main.tf # Defines Terraform providers, modules, and resource creation
├── variables.tf # Defines input variables
├── tfvars/dev.tfvars # Contains variable values for the development environment
├── backend/config.dev.hcl # Backend configuration for Terraform state management
└── README.md # This documentation file

## Backend Configuration

The backend configuration is stored in `backend/config.dev.hcl` and includes:

```hcl
region         = "us-west-2"
key            = "comviva-ecr/terraform.tfstate"
bucket         = "comviva-backend-state-latest"
dynamodb_table = "comviva-state-lock-latest"
encrypt        = true
```

## Variables

| Variable    | Description                        | Default   |
| ----------- | ---------------------------------- | --------- |
| aws_region  | AWS Region for deployment          | us-west-2 |
| namespace   | Project namespace prefix           | None      |
| environment | Deployment environment (dev, prod) | None      |

## Deployment Steps

1. Initialize Terraform with the backend configuration:
   ```sh
   terraform init -backend-config=backend/config.dev.hcl
   ```
2. Plan the deployment:
   ```sh
   terraform plan -var-file=tfvars/dev.tfvars
   ```
3. Apply the deployment:
   ```sh
   terraform apply -var-file=tfvars/dev.tfvars -auto-approve
   ```
4. Destroy the infrastructure (if needed):
   ```sh
   terraform destroy -var-file=tfvars/dev.tfvars -auto-approve
   ```

## Notes

- Ensure that the AWS credentials are correctly configured before running Terraform commands.
- Modify the backend configuration as needed to match your S3 bucket details.
- Using a DynamoDB table (`terraform-lock`) is recommended for state locking to prevent conflicts in multi-user environments.
