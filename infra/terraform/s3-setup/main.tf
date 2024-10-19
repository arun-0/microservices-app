provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "your-terraform-state-bucket"  # Choose a globally unique bucket name
  acl    = "private"

  versioning {
    enabled = true
  }

  # Bucket-wide encryption using AES256
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # or "aws:kms" for KMS-managed encryption
      }
    }
  }

  tags = {
    Name        = "TerraformState"
    Environment = "Production"
  }
}

# Optionally, create a DynamoDB table for state locking (to avoid concurrent modifications)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "TerraformLocks"
    Environment = "Production"
  }
}
