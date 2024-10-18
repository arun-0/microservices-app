provider "aws" {
  region = "us-west-2"  # Change the region as needed
}

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


/*
Terraform for MSK: If you prefer to automate MSK setup with Terraform, add the following to your Terraform main.tf:
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
*/

/*
Full

provider "aws" {
  region = "us-west-2"  # Replace with your desired AWS region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"  # Replace with your desired AZ
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"  # Replace with your desired AZ
}

resource "aws_security_group" "msk_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Modify this for better security
  }
}

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

output "kafka_broker_endpoints" {
  value = aws_msk_cluster.my_kafka.bootstrap_broker_string
}

*/
