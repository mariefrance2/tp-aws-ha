output "alb_dns_name" {
  description = "DNS du Load Balancer"
  value       = aws_lb.pritunl.dns_name
}

output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}

output "rds_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = aws_db_instance.main.endpoint
}

output "s3_bucket_name" {
  description = "Nom du bucket S3"
  value       = aws_s3_bucket.main.bucket
}

output "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  value       = aws_lambda_function.main.function_name
}

output "pritunl_setup_key" {
  description = "Accès Pritunl via ALB"
  value       = "https://${aws_lb.pritunl.dns_name}"
}