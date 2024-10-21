provider "aws" {
  region = "us-east-1"
}

data "aws_secretsmanager_secret" "terraform_state_bucket" {
  name = "terraform_state_bucket"
}

data "aws_secretsmanager_secret_version" "terraform_state_bucket_version" {
  secret_id = data.aws_secretsmanager_secret.terraform_state_bucket.id
}

# Assuming the secret value is a plain string (the S3 bucket name)
output "s3_bucket_name" {
  value = data.aws_secretsmanager_secret_version.terraform_state-bucket.secret_string
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = data.aws_secretsmanager_secret_version.terraform_state_bucket_version.secret_string  # Use the secret value
  force_destroy = true	  # Automatically delete all objects, including versions, before destroying the bucket
  tags = {
    Name        = "TerraformState"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_policy" "secure_access" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          "AWS": "arn:aws:iam::903160062226:user/arun"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}",
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  # Encryption using AES256
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # or "aws:kms" for KMS-managed encryption
    }
  }
}

# Delete the existing DynamoDB table if it exists
resource "null_resource" "delete_dynamodb_table" {
  provisioner "local-exec" {
    command = "aws dynamodb delete-table --table-name terraform-locks 2>nul || exit 0"
  }
  
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Wait for DynamoDB table deletion to complete
resource "null_resource" "wait_for_dynamodb_deletion" {
  depends_on = [null_resource.delete_dynamodb_table]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for DynamoDB table deletion..."
      until ! aws dynamodb describe-table --table-name terraform-locks 2>/dev/null; do
        echo "Table still exists, waiting..."
        sleep 10
      done
      echo "DynamoDB table deletion confirmed."
    EOT
  }
}

# Create the DynamoDB table for state locking (to avoid concurrent modifications)
resource "aws_dynamodb_table" "terraform_locks" {
  count = 1

  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  # Ensure that this resource depends on the deletion confirmation
  depends_on = [null_resource.wait_for_dynamodb_deletion]

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = "TerraformLocks"
    Environment = "Production"
  }
}
