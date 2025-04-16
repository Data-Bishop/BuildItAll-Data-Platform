resource "aws_iam_role" "emr_default_role" {
  name = "EMR_DefaultRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name        = "${var.project_name}-EMR-Default-Role"
    Environment = "Prod"
  }
}

resource "aws_iam_role_policy_attachment" "emr_default_policy" {
  role       = aws_iam_role.emr_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role_policy" "emr_s3_policy" {
  name = "${var.project_name}-EMR-S3-Policy"
  role = aws_iam_role.emr_default_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::builditall-client-data",
          "arn:aws:s3:::builditall-client-data/*",
          "arn:aws:s3:::builditall-logs",
          "arn:aws:s3:::builditall-logs/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "emr_ec2_default_role" {
  name = "EMR_EC2_DefaultRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name        = "${var.project_name}-EMR-EC2-Default-Role"
    Environment = "Prod"
  }
}

resource "aws_iam_role_policy_attachment" "emr_ec2_default_policy" {
  role       = aws_iam_role.emr_ec2_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_role_policy" "emr_ec2_s3_policy" {
  name = "${var.project_name}-EMR-EC2-S3-Policy"
  role = aws_iam_role.emr_ec2_default_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::builditall-client-data",
          "arn:aws:s3:::builditall-client-data/*",
          "arn:aws:s3:::builditall-logs",
          "arn:aws:s3:::builditall-logs/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "emr_ec2_profile" {
  name = "${var.project_name}-EMR-EC2-Profile"
  role = aws_iam_role.emr_ec2_default_role.name
}