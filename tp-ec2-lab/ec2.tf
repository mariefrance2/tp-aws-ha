# ─── AMI Amazon Linux 2023 ────────────────────────────────────
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─── Clé SSH ──────────────────────────────────────────────────
resource "tls_private_key" "hotel" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "hotel" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.hotel.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.hotel.private_key_pem
  filename        = "${path.module}/hotel-key.pem"
  file_permission = "0600"
}

# ─── Instance EC2 ─────────────────────────────────────────────
resource "aws_instance" "hotel" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.hotel.key_name
  vpc_security_group_ids = [aws_security_group.ec2_hotel.id]

  # Volume racine 8 Go gp3
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    tags = {
      Name    = "${var.project_name}-root-volume"
      Project = var.project_name
    }
  }

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name    = "${var.project_name}-instance"
    Project = var.project_name
  }
}