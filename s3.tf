# ─── Bucket S3 ───────────────────────────────────────────────
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-storage-${random_id.bucket_suffix.hex}"

  tags = {
    Name    = "${var.project_name}-bucket"
    Project = var.project_name
  }
}

# ─── Suffix aléatoire pour nom unique ────────────────────────
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ─── Bloquer accès public ─────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── Versioning activé ───────────────────────────────────────
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ─── Chiffrement SSE-S3 ──────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}