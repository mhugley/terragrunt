variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "name" {
  description = "Name of the EC2 instance and security group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.small or larger for heavy tools)"
  type        = string
  default     = "t3.small"
}

variable "vpc_id" {
  description = "VPC ID where the instance and security group will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance (e.g. a public subnet for SSH access)"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
  default     = null
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH (22). Use your IP only, e.g. [\"1.2.3.4/32\"]"
  type        = list(string)
}

variable "allowed_gateway_cidrs" {
  description = "CIDR blocks allowed for optional gateway port. Defaults to allowed_ssh_cidrs when null."
  type        = list(string)
  default     = null
}

variable "enable_gateway_port" {
  description = "Allow TCP on gateway_port (e.g. 18789). Set to false to use SSH port-forwarding only."
  type        = bool
  default     = false
}

variable "gateway_port" {
  description = "Port number for optional gateway ingress (e.g. 18789). Used when enable_gateway_port is true."
  type        = number
  default     = 18789
}

variable "root_volume_size_gb" {
  description = "Root volume size in GB (gp3)"
  type        = number
  default     = 30
}

variable "root_volume_iops" {
  description = "Root gp3 volume IOPS (3000 default; 3000–16000 supported)"
  type        = number
  default     = 3000
}

variable "root_volume_throughput_mbps" {
  description = "Root gp3 volume throughput in MiB/s (125 default; 125–1000)"
  type        = number
  default     = 125
}

variable "root_volume_encrypted" {
  description = "Encrypt the root volume"
  type        = bool
  default     = false
}

variable "associate_public_ip" {
  description = "Associate a public IP (needed for SSH from internet in a public subnet)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
