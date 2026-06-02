output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.main.public_ip
}

output "public_dns" {
  description = "EC2 instance public DNS"
  value       = aws_instance.main.public_dns
}
