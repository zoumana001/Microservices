locals {
  name_prefix = "prod-eks"
  environment = "production"
  region      = "us-east-1"
  
  # Multi-AZ configuration for high availability
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # CIDR blocks
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  
  # EKS Configuration
  cluster_version = "1.30"
  
  # Tags for all resources
  common_tags = {
    Environment = "production"
    Project     = "microservices-platform"
    ManagedBy   = "Terraform"
    Owner       = "platform-Zoumana"
  }
}
