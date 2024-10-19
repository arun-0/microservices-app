# microservices-app

microservices-app/
├── services/
│   ├── userservice/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── java/
│   │   │   │   │   └── com/example/userservice/
│   │   │   │   │       └── UserServiceApplication.java
│   │   │   │   ├── resources/
│   │   │   │       └── application.properties
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   ├── orderservice/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── java/
│   │   │   │   │   └── com/example/orderservice/
│   │   │   │   │       └── OrderServiceApplication.java
│   │   │   │   ├── resources/
│   │   │   │       └── application.properties
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   ├── kafkaproducer/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── java/
│   │   │   │   │   └── com/example/kafkaproducer/
│   │   │   │   │       ├── KafkaProducerApplication.java
│   │   │   │   │       ├── config/
│   │   │   │   │       │   └── KafkaProducerConfig.java
│   │   │   │   │       ├── controller/
│   │   │   │   │           └── MessageController.java
│   │   │   │   ├── resources/
│   │   │   │       └── application.yaml
│   │   ├── Dockerfile
│   │   ├── pom.xml
├── infra/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── helm/
│   │   ├── userservice/
│   │   │   ├── templates/
│   │   │   │   ├── deployment.yaml
│   │   │   │   ├── service.yaml
│   │   │   └── values.yaml
│   │   ├── orderservice/
│   │   │   ├── templates/
│   │   │   │   ├── deployment.yaml
│   │   │   │   ├── service.yaml
│   │   │   └── values.yaml
│   │   ├── kafkaproducer/
│   │   │   ├── templates/
│   │   │   │   ├── deployment.yaml
│   │   │   │   ├── service.yaml
│   │   │   └── values.yaml
│   ├── istio/
│   │   └── virtual-service.yaml
│   └── argocd/
│       └── application.yaml
└── README.md


================================
A resource in Terraform represents an infrastructure component ie a single piece of infrastructure eg such as an EC2 instance, S3 bucket, or VPC.
A module is a container for multiple resources that are used together. It allows for code reusability and organization.
Modules can include resources, data sources, and other modules. They can be local (defined in your own project) or remote (shared and sourced from the Terraform Registry or other repositories).
For example, module "eks" is referencing a pre-defined module for creating an EKS (Elastic Kubernetes Service) cluster, which abstracts away the details and complexities involved in setting up an EKS cluster.


Terraform Example Directory Structure:

terraform/
├── backend.tf		# Separate backend configuration (optional)
├── main.tf			# Main Terraform configuration file
├── variables.tf	# To declare input variables
├── terraform.tfvars# To define default values for the variables defined in variables.tf.
└── outputs.tf		# To declare Terraform outputs
.
├── main.tf            # Main infrastructure resources
├── variables.tf       # Variable declarations
├── terraform.tfvars   # Values for the variables
├── outputs.tf         # Output values for the resources created
├── backend.tf         # Backend configuration for storing state

Other less common OR advanced files
├── provider.tf        # Provider (AWS, GCP, etc.) configuration
├── data.tf            # Data sources to pull existing resources. The data block is used to reference outputs from other Terraform configurations (modules) by reading their state, allowing you to utilize shared resources or configuration details.
├── locals.tf          # Local variables for reuse
├── versions.tf        # Terraform and provider version constraints
├── modules/           # Directory for Terraform modules
│   └── networking/    # Example module for networking resources
├── .terraform/        # Terraform state and provider plugins (generated automatically)
├── .terraform.lock.hcl # Lock file for consistent provider versions
├── test/              # Directory for Terratest or other infrastructure tests
└── scripts/           # Helper or automation scripts (optional)

Less Common Files
	provider.tf
		Specifies the provider configuration (e.g., AWS, Azure, GCP). Defines authentication, regions, and other provider-specific details.
	versions.tf
		Specifies the version constraints for Terraform and any providers. Ensures that you are using specific versions of Terraform and providers for stability.
	data.tf
		Contains data sources that reference external resources without creating them. Useful for referencing existing infrastructure like an existing VPC, AMIs, or security groups.
	locals.tf
		Declares local variables for reuse within the configuration. Allows for computations or reuse of values throughout the Terraform configuration.


Advanced or Rarely Used Files
3.1 outputs.json
	Purpose: Stores outputs from a module in JSON format.
	Usage: Not commonly used but can be useful in automated pipelines or with other tooling that consumes Terraform output.
3.2 override.tf
	Purpose: Used to override the configurations defined in other .tf files.
	Usage: Mostly discouraged because it can complicate configurations, but useful when overriding certain settings for development or testing.
3.3 provider_override.tf
	Purpose: Overrides the provider settings.
	Usage: Rarely used, typically in very specific development or local testing environments.
3.4 terraform.tfstate / terraform.tfstate.backup
	Purpose: Stores the current state of your infrastructure.
	Usage: The terraform.tfstate file keeps track of the resources that Terraform manages, and terraform.tfstate.backup is a backup of the last successful state file.
3.5 terraform.lock.hcl
	Purpose: Lock file generated by Terraform to ensure consistent provider versions.
	Usage: Useful for ensuring that everyone using the project is working with the same versions of the providers.
3.6 output.auto.tfvars
	Purpose: Provides variable values automatically for all files without needing to reference terraform.tfvars.
	Usage: Automatically used by Terraform, which is a less commonly used feature.
3.7 variables.auto.tfvars
	Purpose: Automatically loaded variable file for setting input variables.
	Usage: Automatically loaded without needing a -var-file flag when running terraform plan or apply.
3.8 overrides.tf
	Purpose: Overrides any previously defined configurations.
	Usage: Used to override configurations during local development but discouraged for production use.
3.9 *.tf.json (JSON-formatted .tf files)
	Purpose: JSON equivalent of the .tf configuration files.
	Usage: These files allow you to define Terraform configurations in JSON format instead of the native HCL format. Rarely used in practice but can be beneficial when generating Terraform code programmatically.
3.10 module.tf
	Purpose: A file that can contain module definitions.
	Usage: Organizes reusable modules in one place. These modules can be local or pulled from external sources like Terraform Registry.
3.11 .terraformignore
	Purpose: Similar to .gitignore, this file excludes specific files or directories from being uploaded to remote Terraform modules.
	Usage: Used to avoid pushing unnecessary files to a remote module source.
3.12 .terraformrc or terraform.rc
	Purpose: Configures Terraform's CLI behavior.
	Usage: Used to configure credentials, proxies, or other settings for the CLI tool.
3.13 .terraform directory
	Purpose: This directory contains the downloaded provider plugins, modules, and state-related information.
	Usage: Created automatically when you run terraform init. Not meant for manual editing.
4. Testing and Pipeline Files
	4.1 test/ directory
		Purpose: Contains test files (if you are testing your infrastructure).
		Usage: Tools like Terratest can be used to write unit tests for your Terraform infrastructure.
	4.2 scripts/ directory
		Purpose: Store any helper or automation scripts.
		Usage: You may include bash or python scripts to manage aspects of your Terraform project, such as provisioning, CI/CD integration, etc.
	4.3 ci/ or .github/ directory
		Purpose: Stores CI/CD pipeline configuration for automated infrastructure testing and deployments.
		Usage: Used for integrating Terraform with CI/CD tools like GitHub Actions, GitLab CI, Jenkins, etc.


=============================
Explanation of the Terraform Configuration
	AWS Provider: Sets the AWS region where your resources will be created.
	VPC: Creates a Virtual Private Cloud (VPC) for your Kafka cluster.
	Subnets: Two subnets are created in different availability zones for redundancy.
	Security Group: A security group allows inbound traffic on the Kafka default port (9092).
	MSK Cluster: Creates the Kafka cluster with the specified configuration.
	Output: Displays the Kafka broker endpoints after the cluster is created.
=======================

Typical Helm Chart Directory Structure. Helm will process all Kubernetes manifest .yaml files in the templates/ directory, so you can name them however you like.
However they generally reflect their purpose (e.g., deployment.yaml, service.yaml, ingress.yaml). This helps maintain clarity.

my-helm-chart/
├── Chart.yaml           # Metadata about the chart
├── values.yaml          # Default configuration values
├── templates/           # Directory for Kubernetes manifests
│   ├── deployment.yaml   	# Deployment manifest
│   ├── service.yaml      	# Service manifest
│   ├── ingress.yaml      	# Ingress manifest
│   ├── configmap.yaml    	# ConfigMap manifest
│   ├── secrets.yaml      	# Secret manifest
│   └── _helpers.tpl      	# Helper template functions (optional). You can create a _helpers.tpl file within the templates/ directory to define reusable template functions or variables that can be called throughout your other templates.
└── charts/              # Directory for dependent charts (optional)

========================

Key Components:
Spring Boot Microservices:
	Service A: Handles user requests (e.g., UserService).
	Service B: Processes data (e.g., OrderService).
	Service C: Interacts with external APIs (e.g., PaymentService).
	Kafka will be used for communication between services.
Docker: Each service will have a Dockerfile to containerize the Spring Boot applications.
Kubernetes (K8s): Kubernetes will manage the deployment and scaling of these microservices.
Helm: Used for packaging and deploying Kubernetes configurations.
Istio: To handle traffic management, service discovery, and security between the microservices.
Argo CD: Continuous delivery tool to automate Kubernetes deployments from Git.

We will create a microservices architecture with multiple Spring Boot services that communicate using Kafka for asynchronous messaging. 
The microservices will be containerized using Docker, deployed using Kubernetes with Helm for deployment management. 
Istio will be used to manage service communication and security, while Argo CD will handle continuous deployment (GitOps). 
Finally, we'll discuss integrating the setup with AWS and Terraform for infrastructure provisioning.
multiple layers of infrastructure and application code

==================
Create a new GitHub Repository "microservices-app"
Clone it locally, copy above code and Push it
Install & setup AWS CLI (verify with "aws --version")
aws configure
	Enter your AWS Access Key ID, Secret Access Key, Default region
Install Terraform (verify with "terraform -v")

Firt create:
S3 Bucket to store the Terraform state file.
DynamoDB Table to store state locks for preventing race conditions in multi-user environments.
	cd infra/terraform/s3-setup
	terraform init
	terraform plan
	terraform apply
Now provision the AWS infra:
	cd ..
	terraform init //Re-initialize Terraform to use the S3 backend. Terraform will now migrate your local state to the S3 bucket and use it for future state management.
	terraform plan
	terraform apply


Once the EKS cluster is up, you’ll need to configure kubectl to interact with it.
Install kubectl
Configure kubectl to use EKS:
	Once Terraform completes, it will output the EKS cluster endpoint.
	Run:
		aws eks --region us-east-1 update-kubeconfig --name microservices-cluster

Deploy Kafka, Microservices, and Istio on Kubernetes
Install Helm
(QQ)Kafka Setup in Kubernetes. Deploy Kafka using Helm (Kafka will be deployed using a Helm chart to Kubernetes):
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm install kafka bitnami/kafka --set replicaCount=1


Deploy Your Microservices:
Create a Helm chart for your microservices inside the microservices-app repo.
The helm create command initializes a standard chart structure
ef "helm create service-a-chart" generates:
	service-a-chart
		Chart.yaml: Metadata for the chart.
		values.yaml: Default configuration values for the chart.
		templates/: A directory for Kubernetes manifests (like deployment.yaml, service.yaml, etc.).
		charts/: An empty directory for any dependent charts (this will not contain any sub-charts initially).

	helm create umbrella-chart
	cd umbrella-chart
	helm create charts/userservice
	helm create charts/orderservice
	helm create charts/kafkaproducer
	Update each sub-chart’s Chart.yaml and templates to reflect the specific service configurations.
	Edit the Umbrella Chart's Chart.yaml: Include the dependencies for the sub-charts 

	
Deploy the chart to Kubernetes:
	helm install userservice ./helm/userservice
	example of passing arguments to Helm Chart which takes parameters
	helm install kafkaproducer .helm/kafkaproducer --set image.repository=your-docker-repo/kafkaproducer --set image.tag=latest
	The values.yaml file contains default values for Helm chart parameters. If there is no values.yaml, then default values must be defined directly within the deployment.yaml (or other template files)
Install Istio:
Use istioctl to install Istio:
	istioctl install --set profile=demo
	kubectl label namespace default istio-injection=enabled
Set Up Argo CD for GitOps Continuous Deployment
	Create a Personal Access Token (PAT) on GitHub
	store the PAT as a Kubernetes secret that Argo CD will use to access your GitHub repository.
	Create a secret in the namespace where Argo CD is running (typically argocd)
		kubectl create secret generic argocd-github-creds \
		  --from-literal=username=arun-0 \
		  --from-literal=password=YOUR_GITHUB_PAT \
		  -n argocd

	
Install Argo CD:
	kubectl create namespace argocd
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/mani
Access Argo CD UI:
	kubectl port-forward svc/argocd-server -n argocd 8080:443
Add Your Application to Argo CD:
	Create an application.yaml to point to your GitHub repo with the Kubernetes manifests:
Sync the Application:
	Open Argo CD UI and sync the application to deploy the services automatically.
Monitor and Manage the Application
	Use Istio's dashboard to monitor traffic between your services.
	Use Argo CD's UI to handle deployments, rollbacks, and check the application status.
Next Steps
	Once this basic setup is complete, we can further integrate more advanced Terraform configurations, like auto-scaling, RDS databases, and S3 storage, if needed.
	GitOps or AWS resource configurations

==============================
AWS CLI manual commands

Creating an S3 Bucke
aws s3 mb s3://your-terraform-state-bucket --region us-west-2
getting account ID
aws sts get-caller-identity --query Account --output text
aws iam get-user
aws sts get-caller-identity  # AWS account and the ARN of the IAM user or role

Terraform commands
Terraform will automatically combine all .tf files in the same directory during execution, so separating your outputs into a different file is perfectly fine.

terraform init
terraform plan
Terraform plan -out=tfplan
terraform apply
terraform apply "tfplan"
terraform state list
terraform state show aws_s3_bucket.terraform_state

==============================

to Create an AWS MSK Cluster on web UI:

Go to Amazon MSK.
Click Create cluster.
Choose Custom Create to configure your settings.
For Instance type, choose kafka.m5.large (it's the basic tier but has an hourly cost).
Choose Free Tier-Eligible instance types if available.
Set the number of brokers to 2 or 3.
Proceed with default settings and create the cluster.

================

"from_port" of ingress = the lower bound of the port of this host itself where it can accept the traffic
"to_port" of ingress = the upper bound of the port of this host itself where it can accept the traffic


"from_port" of egress = the port of this host
"to_port" of egress = the port of the recieving end


=======================
Ingress & Egress on AWS

NOTE:- http servers listens on specific port (say 80) they still respond to the VERY SAME http request using an ephemeral port.

ingress {
  from_port   = The lower bound of the port range on this host where it will accept incoming traffic.
  to_port     = The upper bound of the port range on this host where it will accept incoming traffic.
}

egress {
  from_port   = It is meant not to be used at all. However it means "the port on this host that is used to send traffic from". (Often set to 0 or ignored, as it's typically an ephemeral port)
  to_port     = The port on the receiving end (the destination) where the traffic is sent.
}

-----

[1] Default Ingress: deny all inbound traffic
All below 3, Allows traffic from any originating port of the sender, to port 80 of this host.
Rest all ports on this host are not going to see traffic
[2]
ingress {
	from_port = 80
	to_port = 80
}
[3]
ingress {
	from_port = 80
}
[4]
ingress {
	to_port = 80 
}
Since default Egress is "Allow All outgoing traffic", just setting ingress is enough (practically. may or may not be good security-wise though)

--------
Default Egress:
[1] AWS default egress policy = allow all outbound traffic.
from_port is prohibited. Because be it a http-sever or kafka consumer/producer, they all use ephemeral ports for outgoing traffic.
Either DONT use from_port, or set it to zero.
[2]
Only practical scenario:
egress {
    from_port = 0
    to_port = 80/9092 # or any fixed port
}
and
egress {
    to_port = 80/9092 # or any fixed port
}
Allows all traffic sent to port 80/9092 of the reciever

[3]
egress {
	from_port = 80 # or any fixed port
}
AND
egress {
	from_port = 80 # or any fixed port
	to_port = 80
}
Both are a conceptual bug. this server wont respond to any traffic as a http server uses ephemeral port
However first one means,  "traffic from 80 of this host to any port of the recieving host".
However second one means, "traffic from 80 of this host to port 80 of the recieving host".

[3]
default [means no egress rule at all}
and
egress {
    from_port = 0
    to_port = 0
}
and
egress {
    to_port = 0
}
and
egress {
    from_port = 0
}
All means same. All allow all egress traffic
[5]
The only meaningful egress config is
egress {
    from_port = 0
    to_port = 80/9092 # or any fixed port
}
and
egress {
    to_port = 80/9092 # or any fixed port
}
AND
[6]
  # Egress rule to deny all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = []     # An empty list means no outbound traffic is allowed
  }
-----
