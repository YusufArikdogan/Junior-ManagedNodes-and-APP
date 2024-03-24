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

variable "user" {
  default = "yusuf"
}

variable "tags" {
  default = ["react", "nodejs", "postgresql"]
}

resource "aws_instance" "managed_nodes" {
  ami                    = "ami-0230bd60aa48260c6"
  count                  = 3
  instance_type          = "t2.micro"
  key_name               = "yusufkey"
  vpc_security_group_ids = [aws_security_group.react_security_group.id, aws_security_group.nodejs_security_group.id, aws_security_group.postgresql_security_group.id]
  iam_instance_profile   = "junior-level-profile-${var.user}"
  tags = {
    Name        = "ansible_${element(var.tags, count.index)}"
    stack       = "junior_level"
    environment = "development_1"
  }
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    EOF
}

resource "aws_security_group" "react_security_group" {
  name = "react-security-group"
  tags = {
    Name = "react Security Group"
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "nodejs_security_group" {
  name = "nodejs-security-group"
  tags = {
    Name = "nodejs Security Group"
  }

  ingress {
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    security_groups  = [aws_security_group.postgresql_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "postgresql_security_group" {
  name = "postgresql-security-group"
  tags = {
    Name = "postgresql Security Group"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
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

output "react_security_group_id" {
  value = aws_security_group.react_security_group.id
}

output "nodejs_security_group_id" {
  value = aws_security_group.nodejs_security_group.id
}

output "postgresql_security_group_id" {
  value = aws_security_group.postgresql_security_group.id
}
