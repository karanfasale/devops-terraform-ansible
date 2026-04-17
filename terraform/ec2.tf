resource "aws_key_pair" "deployer" {
  key_name   = var.enable_ec2_ssh_key
  public_key = file("/home/ubuntu/.ssh/aws-ec2-key.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  count                = var.instance_count
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = count.index == 0 ? aws_subnet.public_1.id : aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name             = aws_key_pair.deployer.key_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_endpoint = aws_db_instance.mysql.endpoint
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = var.db_password
  }))

  tags = {
    Name        = "${var.environment}-web-${count.index + 1}"
    Environment = var.environment
    Role        = "web-server"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.environment}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

