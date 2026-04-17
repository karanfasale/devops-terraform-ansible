variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "myappdb"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  default     = "ChangeMe_123"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "Subnet 1 CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_2_cidr" {
  description = "Subnet 2 CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_1_cidr" {
  description = "DB Subnet 1 CIDR"
  type        = string
  default     = "10.0.3.0/24"
}

variable "db_subnet_2_cidr" {
  description = "DB Subnet 2 CIDR"
  type        = string
  default     = "10.0.4.0/24"
}

variable "enable_ec2_ssh_key" {
  description = "SSH key name for EC2 instances"
  type        = string
  default     = "aws-ec2-key"
}


