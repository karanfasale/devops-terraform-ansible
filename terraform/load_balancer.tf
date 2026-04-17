resource "aws_elb" "main" {
  name            = "${var.environment}-web-lb"
  security_groups = [aws_security_group.lb.id]
  subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances = aws_instance.web[*].id

  tags = {
    Name        = "${var.environment}-web-lb"
    Environment = var.environment
  }
}

