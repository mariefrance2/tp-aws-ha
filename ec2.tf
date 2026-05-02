# ─── AMI Ubuntu 22.04 (eu-north-1) ───────────────────────────
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─── Clé SSH ─────────────────────────────────────────────────
resource "aws_key_pair" "pritunl" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.pritunl.public_key_openssh
}

resource "tls_private_key" "pritunl" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.pritunl.private_key_pem
  filename        = "${path.module}/pritunl-key.pem"
  file_permission = "0600"
}

# ─── User Data : Installation Pritunl ────────────────────────
locals {
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y gnupg

    # Ajout des dépôts Pritunl
    echo "deb https://repo.pritunl.com/stable/apt jammy main" > /etc/apt/sources.list.d/pritunl.list
    apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A

    # Ajout des dépôts MongoDB
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-6.0.list

    apt-get update -y
    apt-get install -y pritunl mongodb-org

    systemctl enable mongod pritunl
    systemctl start mongod pritunl
  EOF
}

# ─── Launch Template ─────────────────────────────────────────
resource "aws_launch_template" "pritunl" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.pritunl.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }
  block_device_mappings {
  device_name = "/dev/sda1"
  ebs {
    volume_size = 20
    volume_type = "gp2"
  }
}

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project_name}-ec2"
      Project = var.project_name
    }
  }
}

# ─── Auto Scaling Group ───────────────────────────────────────
resource "aws_autoscaling_group" "pritunl" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.pritunl.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.pritunl.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}

# ─── Application Load Balancer ───────────────────────────────
resource "aws_lb" "pritunl" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name    = "${var.project_name}-alb"
    Project = var.project_name
  }
}

# ─── Target Group ────────────────────────────────────────────
resource "aws_lb_target_group" "pritunl" {
  name     = "${var.project_name}-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }

  tags = {
    Name    = "${var.project_name}-tg"
    Project = var.project_name
  }
}

# ─── Listener HTTP → redirect HTTPS ──────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.pritunl.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}