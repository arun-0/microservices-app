# QQ - data = refer the output'ted data from other modules
data "terraform_remote_state" "s3_setup" {
  backend = "local"   # Assuming local state is used for the s3-setup
  config = {
    path = "./s3-setup/terraform.tfstate"  # Path to the state file in ./s3-setup
  }
}

# Configure the backend to store the Terraform state in S3 (can go in backend.tf)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Adjust this to the specific version you need
    }
  }
  required_version = ">= 1.3.0"
  backend "s3" {
    bucket         = "terraform-state-bucket-20241019015747"  # QQ - how to Dynamically use the created bucket. may be using script or CI/CD pipeline??. As The backend configuration in Terraform does not support dynamic values like outputs from a terraform_remote_state. It must be a static configuration.
    key            = "microservices-app/terraform.tfstate"	# state path & file within the bucket
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
resource "aws_vpc" "microservices_vpc" {
  cidr_block = "10.0.0.0/16"
}
# Create Subnets
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.microservices_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Replace with your desired AZ
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.microservices_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"  # Replace with your desired AZ
}


# Create a Security Group for EKS
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.microservices_vpc.id

  # Allow ingress http traffic within the VPC (for internal communication)
  
  # this will limit recieving from kafka [on ephemaral ports]
  #ingress {
  #  from_port   = 80
  #  to_port     = 80
  #  protocol    = "tcp"  # And, "-1" means all protocols
  #  cidr_blocks = ["10.0.0.0/16"]  # Allow traffic from the entire VPC. empty [] means no IP allowed.
  #  description = "Allow HTTP traffic from VPC"
  #}

  # Ingress rule to allow TCP traffic from other microservices on the EKS cluster. [couldnt use self-reference therefore have to use CIDR for entire VPC)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"  # Allow only TCP protocols
    # QQ- cannot self-reference. security_groups = [aws_security_group.eks_sg.id]  # Allow traffic from other pods within the EKS security group
    cidr_blocks = ["10.0.0.0/16"]  # Allow traffic to the entire VPC
    description = "Allow TCP traffic from other services within the cluster"
  }

  # Limit Egress, as the default Egress is to Allow ALL.

  # (if needed) Egress rule for allowing communication with other services within the same security group. cannot do self reference.
  #egress {
  #  from_port   = 0
  #  to_port     = 0
  #  protocol    = "tcp"  # Allow only TCP protocols
  #  security_groups = [aws_security_group.eks_sg.id]  # Allow traffic to other pods within the EKS security group
  #  description = "Allow TCP traffic to other services within the cluster"
  #}

  # Egress rule to only allow TCP traffic from other microservices/Kafka on the EKS cluster. but cannot have cycle therefore using CIDR of entire VPC
  egress {
    from_port   = 0
    to_port     = 8080
    protocol    = "tcp"  # Allow only TCP protocols
    cidr_blocks = ["10.0.0.0/16"]  # Allow traffic to the entire VPC
   description = "Allow TCP traffic to other services within the cluster"
  }

  # Egress rule to only allow traffic to Kafka on its port 9092
  egress {
    from_port   = 0  # Allows traffic from any source port
    to_port     = 9092  # Allows traffic to Kafka on port 9092
    protocol    = "tcp"
    # security_groups = [aws_security_group.msk_sg.id]  # Allow traffic to the Kafka SG. QQ -but this cause cycle therefore using VPC DICR as below
    cidr_blocks = ["10.0.0.0/16"]  # Allow traffic to the entire VPC
    description = "Allow traffic to Kafka on port 9092"
  }

}

# Create a Security Group for MSK. Kafka accepting traffic only onto 9092
resource "aws_security_group" "msk_sg" {
  vpc_id = aws_vpc.microservices_vpc.id
  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]  # For demo purposes, restrict this in production. Modify this for better security
	security_groups = [aws_security_group.eks_sg.id]  # Allow traffic from EKS SG
  }
}

# Create an MSK Cluster (Kafka) (If you prefer to automate MSK setup with Terraform)
resource "aws_msk_cluster" "msk_kafka" {
  cluster_name           = "msk-kafka-cluster"
  kafka_version          = "2.6.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = "kafka.t3.small"  # Use a cheaper instance type. or "kafka.t3.small"
    client_subnets  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    security_groups = [aws_security_group.msk_sg.id]
    #ebs_volume_size = 50     # Reduce size as necessary. or 100
    #ebs_volume_type = "st1"  # General Purpose SSD for cost-effectiveness. or "gp2" for more performance
  }

  # was not enabled on creation. can enable it next time
  #logging_info {
  #  broker_logs {
  #    cloudwatch_logs {
  #      enabled         = true
  #      log_group       = "msk-cluster-logs"
  #    }
  #    s3 {
  #      enabled         = true
  #      bucket          = aws_s3_bucket.msk_logs_bucket.id
  #      prefix          = "logs"
  #    }
  #  }
  #}

  tags = {
    Name = "MSKKafkaCluster"
  }
}

# Terraform configuration for EKS (Elastic Kubernetes Service), which will host the Kubernetes cluster.
# Notice: it is not service, but uses pre-existing module.
# The parameters provided (cluster_name, cluster_version, subnets, and vpc_id) are inputs to the module. They tell the module how to configure the EKS cluster based on your specific requirements.
# The parameters provided (cluster_name, cluster_version, subnets, and vpc_id) are inputs to the module. They tell the module how to configure the EKS cluster based on your specific requirements.
module "eks_cluster" {		# string "eks_cluster" can be anything, it serves as a local reference for this module within your Terraform configuration, making it easier to reference the module's outputs or resources later in your code.
  source          = "terraform-aws-modules/eks/aws"		# This specifies where the module is coming from. In this case, it's pulling the EKS module from the Terraform Registry. This module is pre-defined and includes all the necessary configurations to create and manage an EKS cluster.
  cluster_name    = "microservices-cluster"
  cluster_version = "1.27"  # Or latest version
  vpc_id          = aws_vpc.microservices_vpc.id  # Replace with your VPC ID
  subnet_ids  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]  # Replace with your subnets
  # vpc_cni_enabled = true  # Enable VPC CNI for networking. QQ - not supported
  cluster_security_group_id = aws_security_group.eks_sg.id  # Use the EKS security group
}



# Secrets for EKS Cluster Endpoint
resource "aws_secretsmanager_secret" "eks_cluster_secret" {
  name        = "eks-cluster-endpoint"
  description = "EKS Cluster Endpoint"
}
resource "aws_secretsmanager_secret_version" "eks_cluster_secret_value" {
  secret_id     = aws_secretsmanager_secret.eks_cluster_secret.id
  secret_string = module.eks_cluster.cluster_endpoint
}

# Secrets for Kafka Broker Endpoints
resource "aws_secretsmanager_secret" "kafka_broker_secret" {
  name        = "kafka-broker-endpoints"
  description = "Kafka Broker Endpoints"
}
resource "aws_secretsmanager_secret_version" "kafka_broker_secret_value" {
  secret_id     = aws_secretsmanager_secret.kafka_broker_secret.id
  secret_string = aws_msk_cluster.msk_kafka.bootstrap_brokers_tls
}

# aws secretsmanager get-secret-value --secret-id eks-cluster-endpoint --query SecretString --output text
# aws secretsmanager get-secret-value --secret-id kafka-broker-endpoints --query SecretString --output text


# New Secrets for Kafka PEM and Truststore
resource "aws_secretsmanager_secret" "kafka_truststore_secret" {
  name        = "kafka-truststore"
  description = "Kafka Truststore"
}

resource "aws_secretsmanager_secret" "kafka_pem_secret" {
  name        = "kafka-pem"
  description = "Kafka PEM"
}