# ─── Volume EBS gp3 10 Go ─────────────────────────────────────
resource "aws_ebs_volume" "data" {
  availability_zone = aws_instance.hotel.availability_zone
  size              = 10
  type              = "gp3"

  tags = {
    Name    = "${var.project_name}-data-volume"
    Project = var.project_name
  }
}

# ─── Attacher le volume à l'instance ─────────────────────────
resource "aws_volume_attachment" "data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.hotel.id
}