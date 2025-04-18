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
              sudo yum update -y
              sudo amazon-linux-extras install docker
              sudo service docker start
              sudo systemctl enable docker
              sudo docker run -d -p 80:1337 abhishekgosavii2000/my-strapi-app:${var.image_tag}
              EOF
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
