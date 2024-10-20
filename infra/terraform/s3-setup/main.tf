provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-${formatdate("YYYYMMDDHHmmss", timestamp())}"  # Using a timestamp for global uniqueness
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

# Check if the DynamoDB table exists. Attempt to read the existing DynamoDB table
data "aws_dynamodb_table" "existing_table" {
  name = "terraform-locks"
}

# Delete the existing DynamoDB table if it exists
#resource "null_resource" "delete_dynamodb_table" {
#  count = length(data.aws_dynamodb_table.existing_table) > 0 ? 1 : 0
#
#  provisioner "local-exec" {
#    command = "aws dynamodb delete-table --table-name terraform-locks"
#  }
#
#  triggers = {
#    always_run = "${timestamp()}"
#  }
#}

# Create/Reuse a DynamoDB table for state locking (to avoid concurrent modifications)
resource "aws_dynamodb_table" "terraform_locks" {
  count = length(data.aws_dynamodb_table.existing_table) > 0 ? 0 : 1

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
