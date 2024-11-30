resource "aws_iam_role" "frontend" {
  name = "frontend"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_full_access" {
  name        = "s3_full_access_policy"
  description = "Policy to allow full access to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "frontend_attach" {
  role       = aws_iam_role.frontend.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}

resource "aws_iam_instance_profile" "frontend_profile" {
  name = "frontend-profile"
  role = aws_iam_role.frontend.name
}