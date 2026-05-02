# ─── Security Group : EC2 Hotel ──────────────────────────────
resource "aws_security_group" "ec2_hotel" {
  name        = "${var.project_name}-sg"
  description = "SSH depuis mon IP uniquement + HTTP public"
  vpc_id      = data.aws_vpc.default.id

  # SSH uniquement depuis votre IP
  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["102.244.42.119/32"]
  }

  # HTTP ouvert à tout internet
  ingress {
    description = "HTTP public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# ─── VPC par défaut (déjà existant dans AWS) ─────────────────
data "aws_vpc" "default" {
  default = true
}