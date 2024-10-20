output "terraform_state_bucket" {
  description = "The name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_creation_status" {
  description = "Status of the DynamoDB table creation"
  value = length(data.aws_dynamodb_table.existing_table) > 0 ? "Reused existing DynamoDB table: terraform-locks" : "Created new DynamoDB table: terraform-locks"
}