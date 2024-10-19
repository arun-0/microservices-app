# Configure the backend to store the Terraform state in S3 (can go in backend.tf)
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"		# Replace with your S3 bucket name
    key            = "eks-cluster/terraform.tfstate"	# state path & file within the bucket
    region         = "us-east-1"		# replace with you region
    dynamodb_table = "terraform-locks"  # Name of the DynamoDB table for locking
    encrypt        = true				# Additional safeguard for encrypting the state file
  }
}

# AWS Provider configuration
provider "aws" {
  region = "us-east-1"  # Change the region as needed
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
# Create Subnets
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Replace with your desired AZ
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"  # Replace with your desired AZ
}


# Create a Security Group for MSK
resource "aws_security_group" "msk_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For demo purposes, restrict this in production. Modify this for better security
  }
}

# Create an MSK Cluster (Kafka) (If you prefer to automate MSK setup with Terraform)
resource "aws_msk_cluster" "my_kafka" {
  cluster_name           = "my-kafka-cluster"
  kafka_version          = "2.6.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 100
    client_subnets  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    security_groups = [aws_security_group.msk_sg.id]
  }
  tags = {
    Name = "MyKafkaCluster"
  }
}

# Output the Kafka broker endpoints (can go in output.tf)
output "kafka_broker_endpoints" {
  value = aws_msk_cluster.my_kafka.bootstrap_broker_string
}

# Terraform configuration for EKS (Elastic Kubernetes Service), which will host the Kubernetes cluster.
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "microservices-cluster"
  cluster_version = "1.21"  # Or latest version
  subnets         = ["subnet-xyz123", "subnet-abc456"]  # Replace with your subnets
  vpc_id          = "vpc-xyz789"  # Replace with your VPC ID
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
