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
  vpc_security_group_ids = [aws_security_group.app_security_group[0].id]
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

resource "aws_security_group" "app_security_group" {
  count = length(var.tags)

  name = "${var.tags[count.index]}-security-group"
  tags = {
    Name = "${var.tags[count.index]} Security Group"
  }

  dynamic "ingress" {
    for_each = var.tags

    content {
      from_port       = ingress.value == "postgresql" ? 5432 : ingress.value == "nodejs" ? 5000 : 80
      to_port         = ingress.value == "postgresql" ? 5432 : ingress.value == "nodejs" ? 5000 : 80
      protocol        = "tcp"
      cidr_blocks     = ingress.value == "react" ? ["0.0.0.0/0"] : []
      security_groups = ingress.value == "nodejs" ? [aws_security_group.app_security_group[(count.index + 2) % length(var.tags)].id] : []
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "react_security_group_id" {
  value = aws_security_group.app_security_group[0].id
}

output "nodejs_security_group_id" {
  value = aws_security_group.app_security_group[1].id
}

output "postgresql_security_group_id" {
  value = aws_security_group.app_security_group[2].id
}
