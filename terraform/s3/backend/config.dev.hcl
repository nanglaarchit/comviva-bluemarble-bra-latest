region         = "us-west-2"
key            = "comviva-s3/terraform.tfstate"
bucket         = "comviva-backend-state-latest"
dynamodb_table = "comviva-state-lock-latest"
encrypt        = true