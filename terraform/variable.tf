variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-0e35ddab05955cf57"
}

variable "image_tag" {
  description = "The full ECR image URI including tag to deploy"
  type        = string
}



