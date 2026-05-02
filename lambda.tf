# ─── Rôle IAM pour Lambda ─────────────────────────────────────
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-lambda-role"
    Project = var.project_name
  }
}

# ─── Policy Lambda : logs CloudWatch ─────────────────────────
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ─── Archive du code Lambda ───────────────────────────────────
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = <<-EOF
      def handler(event, context):
          print("Pritunl HA - Lambda triggered")
          print(f"Event: {event}")
          return {
              "statusCode": 200,
              "body": "Lambda OK"
          }
    EOF
    filename = "lambda_function.py"
  }
}

# ─── Fonction Lambda ──────────────────────────────────────────
resource "aws_lambda_function" "main" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-function"
  role             = aws_iam_role.lambda.arn
  handler          = "lambda_function.handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      PROJECT = var.project_name
    }
  }

  tags = {
    Name    = "${var.project_name}-lambda"
    Project = var.project_name
  }
}