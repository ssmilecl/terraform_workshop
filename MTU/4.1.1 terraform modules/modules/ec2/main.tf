# EC2 Module - Child Module
# This module creates compute resources using networking from the VPC module

# Launch template for EC2 instances
resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-web-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name != "" ? var.key_pair_name : null

  vpc_security_group_ids = [var.web_security_group_id]

  # Simple, bulletproof user data script
  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${local.name_prefix}-web-instance"
      Type = "Web Server"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 instances using launch template
resource "aws_instance" "web" {
  count = length(var.public_subnet_ids)

  subnet_id = var.public_subnet_ids[count.index]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-web-${count.index + 1}"
    Type = "Web Server Instance"
  })
}

# Application Load Balancer
resource "aws_lb" "web" {
  name               = "${local.name_prefix}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-web-alb"
    Type = "Application Load Balancer"
  })
}

# Target group for the load balancer
resource "aws_lb_target_group" "web" {
  name     = "${local.name_prefix}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-web-tg"
    Type = "Target Group"
  })
}

# Attach instances to target group
resource "aws_lb_target_group_attachment" "web" {
  count = length(aws_instance.web)

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Load balancer listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.web.arn
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-web-listener"
    Type = "Load Balancer Listener"
  })
}
