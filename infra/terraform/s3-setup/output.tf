output "terraform_state_bucket" {
  description = "The name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_creation_status" {
  description = "Status of the DynamoDB table creation"
  value = (null_resource.check_dynamodb_table.provisioner.local-exec.stdout == "not_found") ? "Created new DynamoDB table: terraform-locks" : "Reused existing DynamoDB table: terraform-locks"
}