# AWS VPC Project - Version 2 (Cost-Optimized with Spot Instances)
# This version uses 70% Spot + 30% On-Demand instances for cost savings

provider "aws" {
  region = var.aws_region
}

# VPC + Networking (same as V1 - reuse or copy configurations)
# ... [Include VPC, Subnets, IGW, Route Tables from V1] ...

# Security Groups (same as V1)
# ... [Include Security Groups from V1] ...

# Load Balancer (same as V1)
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-v2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-alb-v2"
  }
}

# Launch Template for Mixed Instances
resource "aws_launch_template" "web" {
  name_prefix   = "spot-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/../scripts/user-data.sh", {
    project_name = var.project_name
  }))

  vpc_security_group_ids = [aws_security_group.web.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web-server"
    }
  }
}

# Target Group
resource "aws_lb_target_group" "web" {
  name        = "${var.project_name}-tg-v2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg-v2"
  }
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Auto Scaling Group with Mixed Instances (70% Spot + 30% On-Demand)
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-asg-v2"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  health_check_type   = "ELB"
  health_check_grace_period = 300

  # Mixed Instances Policy - 70% Spot, 30% On-Demand
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.web.id
        version            = "$Latest"
      }
      override {
        instance_type = var.instance_type
      }
    }

    instances_distribution {
      on_demand_percentage_above_base_capacity = 30
      spot_allocation_strategy                 = "capacity-optimized"
      spot_instance_pools                      = 3
      spot_max_price                           = var.spot_max_price
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
