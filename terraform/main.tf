provider "aws" {
  region = "ap-south-1"
}

# Declare the image_tag variable
variable "image_tag" {
  description = "The Docker image tag, ECR image URI"
  type        = string
}

# Create an EC2 instance for Strapi
resource "aws_instance" "strapi" {
  ami                    = "ami-0f1dcc636b69a6438" # Replace with a valid AMI ID for your region
  instance_type           = "t3.micro"
  key_name                = "abhi18"               # Replace with your key pair name
  associate_public_ip_address = true
  vpc_security_group_ids  = [aws_security_group.strapi_sg.id]

  user_data = <<-EOF
             #!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 118273046134.dkr.ecr.ap-south-1.amazonaws.com
docker pull 118273046134.dkr.ecr.ap-south-1.amazonaws.com/${var.image_tag}
docker run -d -p 80:1337 118273046134.dkr.ecr.ap-south-1.amazonaws.com/${var.image_tag}
              EOF

  tags = {
    Name = "Strapi-EC2-GBK"
  }
}

# Security group for the Strapi app
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-GBKGB"
  description = "Allow HTTP, SSH, and Strapi traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

  ingress {
    description = "Strapi"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}
































# provider "aws" {
#   region = "ap-south-1"
# }

# resource "aws_instance" "strapi" {
#   ami                    = "ami-0f1dcc636b69a6438" # Replace with a valid AMI ID for your region
#   instance_type          = "t3.micro"
#   key_name               = "abhi18"               # Replace with your key pair name
#   associate_public_ip_address = true
#   vpc_security_group_ids = [aws_security_group.strapi_sg.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               amazon-linux-extras install docker -y
#               service docker start
#               usermod -a -G docker ec2-user
#               curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#               unzip awscliv2.zip
#               sudo ./aws/install
#               aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 118273046134.dkr.ecr.us-east-1.amazonaws.com
#               docker pull 118273046134.dkr.ecr.us-east-1.amazonaws.com/gbk-strapi-app:latest
#               docker run -d -p 80:1337 118273046134.dkr.ecr.us-east-1.amazonaws.com/gbk-strapi-app:latest
#               EOF

#   tags = {
#     Name = "Strapi-EC2-GBK"
#   }
# }

# resource "aws_security_group" "strapi_sg" {
#   name        = "strapi-sg-GBKGB"
#   description = "Allow HTTP and SSH"
#   vpc_id      = data.aws_vpc.default.id

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#   from_port   = 1337
#   to_port     = 1337
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   description = "Allow Strapi"
# }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# data "aws_vpc" "default" {
#   default = true
# }
