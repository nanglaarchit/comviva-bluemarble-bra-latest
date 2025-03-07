# Terraform AWS Bedrock Agents Bootstrap

## Overview

This Terraform configuration sets up AWS Bedrock Agents, including a Supervisor Agent and two collaborating agents (Single Rule Generation Agent and Bulk Rule Operations Agent). It also configures the necessary S3 backend for state management and DynamoDB for state locking.

## Prerequisites

Ensure you have the following installed and configured:

- Terraform (>=1.3, <2.0.0)
-
- An S3 bucket and DynamoDB table for remote state storage

## Module Configuration

This configuration consists of the following key components:

- **Supervisor Agent**
- **Single Rule Generation Agent**: 
- **Bulk Rule Operations Agent**: 

## Files Overview

├── main.tf # Defines Terraform providers, modules, and resource creation
├── variables.tf # Defines input variables
├── tfvars/dev.tfvars # Contains variable values for the development environment
├── backend/config.dev.hcl # Backend configuration for Terraform state management
└── README.md # This documentation file

## Backend Configuration

The Terraform state is managed using an S3 bucket with DynamoDB for state locking. The backend configuration is stored in `backend/config.dev.hcl`:

```hcl
region         = "us-east-1"
key            = "comviva-bedrock-agents/terraform.tfstate"
bucket         = "comviva-backend-state-latest"
dynamodb_table = "comviva-state-lock-latest"
encrypt        = true
```

## Deployment Steps

### 1. Initialize Terraform

```sh
terraform init -backend-config=backend/config.dev.hcl
```

### 2. Plan the Deployment

```sh
terraform plan -var-file=tfvars/dev.tfvars
```

### 3. Apply the Deployment

```sh
terraform apply -parallelism=1 -var-file=tfvars/dev.tfvars -auto-approve
```

### 4. Destroy the Deployment (If Needed)

```sh
terraform destroy -parallelism=1 -var-file=tfvars/dev.tfvars -auto-approve
```

## Variables

| Variable          | Description                              | Default                     |
| ----------------- | ---------------------------------------- | --------------------------- |
| `aws_region`      | AWS Region                               | us-west-2                   |
| `namespace`       | Project namespace prefix                 | None                        |
| `environment`     | Deployment environment (e.g., dev, prod) | None                        |
| `supervisor_name` | Name of the Supervisor Agent             | SupervisorAgent             |
| `agent_name1`     | Name of the Single Rule Generation Agent | SingleRuleGenerationAgent   |
| `agent_name2`     | Name of the Bulk Rule Operations Agent   | BulkRuleOperationsAgent     |
| `function_name`   | Name of the Lambda function              | comviva-dev-lambda-function |

## Additional Notes

- Ensure that AWS credentials are properly configured before running Terraform commands.
- Modify variable values in `tfvars/dev.tfvars` as needed for different environments.
- The Bedrock Agent module is sourced from GitHub: `github.com/sourcefuse/terraform-aws-arc-bedrock?ref=feature/bedrock-agent`.

---

This completes the setup and deployment of AWS Bedrock Agents using Terraform. For further customizations, modify the `variables.tf` file accordingly.
AWS CLI installed and configured with the appropriate credentials
