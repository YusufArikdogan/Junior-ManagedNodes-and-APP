terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "junior-level-backend"
    key = "backend/tf-backend-junior-.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "user" {
  default = "yusuf"
}

resource "aws_instance" "managed_nodes" {
  ami                    = "ami-0230bd60aa48260c6"
  count                  = 3
  instance_type          = "t2.micro"
  key_name               = "yusufkey"
  vpc_security_group_ids = [aws_security_group.managed_nodes_sec_group[0].id]
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

variable "managed_nodes" {
  type    = list(string)
  default = ["react", "nodejs", "postgresql"]
}

resource "aws_security_group" "managed_nodes_sec_group" {
  count = length(var.managed_nodes)

  name = "${var.managed_nodes[count.index]}-security-group"
  tags = {
    Name = "${var.managed_nodes[count.index]} Security Group"
  }

  dynamic "ingress" {
    for_each = var.managed_nodes

    content {
      from_port       = ingress.value == "react" ? 80 : ingress.value == "nodejs" ? 5000 : 5432
      to_port         = ingress.value == "react" ? 80 : ingress.value == "nodejs" ? 5000 : 5432
      protocol        = "tcp"
      cidr_blocks     = ingress.value == "postgresql" ? ["0.0.0.0/0"] : []
      security_groups = ingress.value != "postgresql" ? [aws_security_group.managed_nodes_sec_group[(count.index + 1) % length(var.managed_nodes)].id] : []
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "react_ip" {
  value = "http://${aws_instance.managed_nodes[2].public_ip}:80"
}

output "node_public_ip" {
  value = aws_instance.managed_nodes[1].public_ip
}

output "postgre_private_ip" {
  value = aws_instance.managed_nodes[0].private_ip
}
