provider "aws" {
  region = var.region
}

resource "aws_ssm_parameter" "key_name" {
  name  = "/my/strapi/aws_key_name"
  type  = "String"
  value = "my-key-pair"
}

resource "aws_instance" "strapi_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_ssm_parameter.key_name.value

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

  # user_data = <<-EOF
  #             #!/bin/bash
  #             # sudo yum update -y
  #             # sudo amazon-linux-extras install docker
  #             # sudo service docker start
  #             # sudo systemctl enable docker
  #             # sudo docker run -d -p 80:1337 abhishekgosavii2000/my-strapi-app:latest
  #             EOF
}

resource "aws_ssm_document" "ssm_agent" {
  name          = "SSM-Run-Docker"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Run Docker on EC2",
    mainSteps = [
      {
        action = "aws:runShellScript",
        name   = "runShellScript",
        inputs = {
          runCommand = [
            "docker run -d -p 80:1337 abhishekgosavii2000/my-strapi-app:${var.image_tag}"
          ]
        }
      }
    ]
  })
}

variable "region" {}
variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "image_tag" {}
