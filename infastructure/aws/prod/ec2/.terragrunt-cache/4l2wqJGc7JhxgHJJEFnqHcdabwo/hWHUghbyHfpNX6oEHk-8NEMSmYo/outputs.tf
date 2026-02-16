output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance (if associate_public_ip was true)"
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}

output "ami_id" {
  description = "AMI ID used for the instance (Ubuntu 22.04)"
  value       = data.aws_ami.ubuntu.id
}
