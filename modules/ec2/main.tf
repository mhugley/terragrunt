terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Ubuntu 22.04 LTS (Jammy) - latest HVM SSD
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security group: SSH and optional gateway port (18789) from allowed IPs only
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "SSH and optional gateway (18789) from allowed IPs only"
  vpc_id      = var.vpc_id

  # SSH from your IP only
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Optional gateway port (e.g. 18789); set enable_gateway_port = false to use SSH port-forward only
  dynamic "ingress" {
    for_each = var.enable_gateway_port ? [1] : []
    content {
      description = "Gateway"
      from_port   = var.gateway_port
      to_port     = var.gateway_port
      protocol    = "tcp"
      cidr_blocks = coalesce(var.allowed_gateway_cidrs, var.allowed_ssh_cidrs)
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  associate_public_ip_address = var.associate_public_ip

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size_gb
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput_mbps
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
