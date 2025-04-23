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

resource "aws_security_group" "emr_master" {
  name        = "EMR-Master-SG"
  description = "EMR Master Security Group"
  vpc_id      = var.vpc_id

  # SSH access (no dependency on other security groups)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Self-referential traffic
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-EMR-Master-SG"
    Environment = "Prod"
  }
}

resource "aws_security_group" "emr_slave" {
  name        = "EMR-Slave-SG"
  description = "EMR Slave Security Group"
  vpc_id      = var.vpc_id

  # Self-referential traffic
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-EMR-Slave-SG"
    Environment = "Prod"
  }
}

# Master ingress from slave
resource "aws_security_group_rule" "master_from_slave" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.emr_master.id
  source_security_group_id = aws_security_group.emr_slave.id
}

# Slave ingress from master
resource "aws_security_group_rule" "slave_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.emr_slave.id
  source_security_group_id = aws_security_group.emr_master.id
}