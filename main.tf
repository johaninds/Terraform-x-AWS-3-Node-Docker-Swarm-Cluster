provider "aws" {
  region = var.region
}
resource "aws_s3_bucket" "swarm" {
  bucket        = var.bucket_name
  force_destroy = true
}
resource "aws_iam_role" "swarm_role" {
  name = "swarm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "swarm_profile" {
  name = "swarm_profile"
  role = aws_iam_role.swarm_role.name
}

resource "aws_iam_role_policy" "swarm_policy" {
  name = "swarm_policy"
  role = aws_iam_role.swarm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.swarm.arn,
          "${aws_s3_bucket.swarm.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_instance" "manager" {
  ami                  = "ami-036cafe742923b3d9" # Ubuntu 22.04 LTS AMI ID for us-west-2
  instance_type        = var.instance_type
  key_name             = var.key_name # Replace with your actual key name
  iam_instance_profile = aws_iam_instance_profile.swarm_profile.name

  user_data = file("install_docker_manager.sh")

  vpc_security_group_ids = [aws_security_group.swarm-SG.id]

  tags = {
    Name = "swarm-manager"
  }
}


resource "aws_instance" "worker" {
  count                = 2
  ami                  = "ami-036cafe742923b3d9" # Ubuntu 22.04 LTS AMI ID for us-west-2
  instance_type        = var.instance_type
  key_name             = var.key_name # Replace with your actual key name
  iam_instance_profile = aws_iam_instance_profile.swarm_profile.name

  depends_on = [aws_instance.manager]

  user_data              = file("install_docker_worker.sh")
  vpc_security_group_ids = [aws_security_group.swarm-SG.id]

  tags = {
    Name = "swarm-worker-${count.index + 1}"
  }
}

output "manager_ip" {
  value = aws_instance.manager.private_ip
}

output "worker_ips" {
  value = aws_instance.worker[*].private_ip
}

resource "aws_security_group" "swarm-SG" {
  name        = "swarm-SG"
  description = "Allow all inbound and outbound traffic"
  # vpc_id      = aws_vpc.main.id

  # allow inbound traffic from anywhere on all ports and protocols
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow inbound traffic on port 80 for internal connections
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  # allow outbound traffic to anywhere on all ports and protocols
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


