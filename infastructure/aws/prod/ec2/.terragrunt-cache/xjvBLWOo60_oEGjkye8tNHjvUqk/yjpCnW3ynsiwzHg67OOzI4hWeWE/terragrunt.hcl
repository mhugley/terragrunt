terraform {
  source = "../../../../modules/ec2/"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id            = "vpc-mock"
    public_subnet_ids = ["subnet-mock"]
  }
}

inputs = {
  aws_region    = "us-east-1"
  name          = "openclaw-gateway"
  instance_type = "t3.small"

  vpc_id    = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.public_subnet_ids[0]

  # Set to your EC2 key pair name for SSH access
  key_name = "your-key-name"

  # Your IP only — run: curl -s ifconfig.me  then use ["YOUR_IP/32"] (replace 0.0.0.0/32 below)
  allowed_ssh_cidrs = ["0.0.0.0/32"]

  # Allow OpenClaw gateway on 18789 from same IP; set to false to use SSH port-forward only
  enable_openclaw_gateway_port = true

  tags = {
    Environment = "dev"
    Project     = "Neptune"
  }
}
