output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_elb.main.dns_name
}

output "ec2_instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.web[*].id
}

output "ec2_private_ips" {
  description = "Private IPs of EC2 instances"
  value       = aws_instance.web[*].private_ip
}

output "ec2_public_ips" {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_address" {
  description = "RDS address"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.mysql.port
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

