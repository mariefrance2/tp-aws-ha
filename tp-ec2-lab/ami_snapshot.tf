# ─── Snapshot du volume racine ────────────────────────────────
resource "aws_ebs_snapshot" "root_snapshot" {
  volume_id = aws_instance.hotel.root_block_device[0].volume_id

  tags = {
    Name    = "${var.project_name}-root-snapshot"
    Project = var.project_name
  }

  depends_on = [aws_instance.hotel]
}

# ─── AMI personnalisée depuis le snapshot ─────────────────────
resource "aws_ami" "hotel_ami" {
  name                = "${var.project_name}-ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot.root_snapshot.id
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name    = "${var.project_name}-custom-ami"
    Project = var.project_name
  }
}