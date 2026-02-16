terraform {
  # Use the local VPC module
  source = "../../../../modules/vpc/"
}

inputs = {
  # Core settings
  aws_region = "us-east-1"
  vpc_name   = "Neptune"
  vpc_cidr   = "10.0.0.0/16"

  # We want 3 public + 3 private subnets across 3 AZs
  az_count = 3
  # Leave empty to automatically pick the first 3 AZs in the region
  azs = []

  # Adjust CIDR blocks as needed
  public_subnet_cidrs = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  private_subnet_cidrs = [
    "10.0.100.0/24",
    "10.0.101.0/24",
    "10.0.102.0/24",
  ]

  # Optional extra tags
  tags = {
    Environment = "dev"
    Project     = "Neptune"
  }
}

