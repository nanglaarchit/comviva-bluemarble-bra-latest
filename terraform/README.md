# AWS DevOps Infrastructure Setup

This repository contains Terraform configurations for setting up a complete AWS DevOps infrastructure. Follow the steps in the order mentioned below to ensure a smooth deployment.

## Steps to Follow

### 1. Bootstrap: Setup Terraform Backend State
- Go to the `bootstrap` directory.
- Comment out the `backend "s3" {}` block in `main.tf`.
- Initialize Terraform without backend:
  ```sh
  terraform init -backend-config=backend/config.dev.hcl
  ```
- Apply Terraform to create the required S3 bucket and DynamoDB table:
  ```sh
  terraform apply -var-file=tfvars/dev.tfvars
  ```
- Uncomment the `backend "s3" {}` block in `main.tf`.
- Reinitialize Terraform to migrate state into S3:
  ```sh
  terraform init -backend-config=backend/config.dev.hcl
  ```

### 2. ECR: Setup Elastic Container Registry
- Go to the `ecr` directory.
- Initialize Terraform with the backend configuration:
  ```sh
  terraform init -backend-config=backend/config.dev.hcl
  ```
- Plan and apply the deployment:
  ```sh
  terraform plan -var-file=tfvars/dev.tfvars
  terraform apply -var-file=tfvars/dev.tfvars -auto-approve
  ```

### 3. Containerize and Push Docker Image to ECR
- Build your Docker image.
- Authenticate Docker to your AWS ECR.
- Tag and push the image using the commands from the AWS ECR console.

### 4. Store Docker Image URI in SSM Parameter Store
After successfully pushing the Docker image to ECR, store the image URI in AWS Systems Manager Parameter Store. This ensures that other AWS services, such as Lambda or ECS, can easily retrieve the latest image without hardcoding it. The image URI will be stored under the parameter name `/comviva/bra-docker-image-uri`.

### 5. S3: Setup S3 Bucket
- Go to the `s3` directory.
- Initialize Terraform with the backend configuration:
  ```sh
  terraform init -backend-config=backend/config.dev.hcl
  ```
- Plan and apply the deployment:
  ```sh
  terraform plan -var-file=tfvars/dev.tfvars
  terraform apply -var-file=tfvars/dev.tfvars -auto-approve
  ```

### 6. Lambda: Deploy AWS Lambda Function
- Go to the `lambda` directory.
- Initialize Terraform with the backend configuration:
  ```sh
  terraform init -backend-config=backend/config.dev.hcl
  ```
- Plan and apply the deployment:
  ```sh
  terraform plan -var-file=tfvars/dev.tfvars
  terraform apply -var-file=tfvars/dev.tfvars -auto-approve
  ```

### 7. Bedrock Agents: Setup AWS Bedrock Agents
- Go to the `bedrock agents` directory.
- Initialize Terraform with the backend configuration:
  ```sh
  terraform init -backend-config=backend/config.dev.hcl
  ```
- Plan and apply the deployment:
  ```sh
  terraform plan -var-file=tfvars/dev.tfvars
  terraform apply -parallelism=1 -var-file=tfvars/dev.tfvars -auto-approve
  ```

## Notes
- Ensure your AWS credentials are configured correctly before running Terraform commands.
- Modify variable values in `tfvars/dev.tfvars` as needed for different environments.
- Use DynamoDB state locking to prevent conflicts in multi-user environments.
