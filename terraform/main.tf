provider "aws" {
  region = var.aws_region
}

# IAM Role for EC2 with Administrator Access
resource "aws_iam_role" "ec2_admin_role" {
  name = "ec2-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.ec2_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-admin-profile"
  role = aws_iam_role.ec2_admin_role.name
}

# Key Pair
resource "aws_key_pair" "strapi_key" {
  key_name   = "strapi-key"
  public_key = file("${path.module}/keys/id_rsa.pub")
}


# Security Group
resource "aws_security_group" "strapi_sg" {
  name        = "abhi19"
  description = "Allow SSH, HTTP, HTTPS, and Strapi port"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Strapi"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "strapi_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.strapi_key.key_name
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -x
              exec > /var/log/user-data.log 2>&1
              apt-get update -y
              apt-get install -y docker.io 
              sudo apt update && sudo apt install -y unzip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              systemctl start docker
              systemctl enable docker 
              aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 626635402783.dkr.ecr.us-east-1.amazonaws.com
              docker pull ${var.image_tag}
              docker run -d -p 1337:1337 --restart always --name strapi \ ${var.image_tag}
              EOF

  tags = {
    Name = "StrapiApp"
  }
}

# Output
output "instance_public_ip" {
  value = aws_instance.strapi_ec2.public_ip
}
