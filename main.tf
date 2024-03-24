terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "tags" {
  default = ["postgresql", "nodejs", "react"]
}

variable "user" {
  default = "yusuf"
}

resource "aws_instance" "managed_nodes" {
  ami                    = "ami-0230bd60aa48260c6"
  count                  = 3
  instance_type          = "t2.micro"
  key_name               = "yusufkey"
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  iam_instance_profile   = "junior-level-profile-${var.user}"
  tags = {
    Name        = "ansible_${element(var.tags, count.index)}"
    stack       = "junior_level"
    environment = "development_1"
  }
  
  user_data = <<EOF
  #!/bin/bash
  dnf update -y
  EOF
}

resource "aws_security_group" "tf-sec-gr" {
  name = "junior-level-sec-gr"
  tags = {
    Name = "junior-level-sec-gr"
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    protocol    = "tcp"
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    protocol    = "tcp"
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "react_ip" {
  value = "http://${aws_instance.managed_nodes[2].public_ip}:3000"
}

output "node_public_ip" {
  value = aws_instance.managed_nodes[1].public_ip
}

output "postgre_private_ip" {
  value = aws_instance.managed_nodes[0].private_ip
}
