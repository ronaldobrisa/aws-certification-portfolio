locals {
  tags = merge({
    Project       = "aws-certification-portfolio"
    Environment   = "study"
    Certification = "cloud-practitioner"
    Module        = "ec2-first-instance"
  }, var.tags)
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "instance" {
  name        = "ec2-first-instance-sg"
  description = "Security group for first EC2 instance"

  # checkov:skip=CKV_AWS_24: estudo — SSH liberado via variável allowed_ssh_cidr para demonstração
  # checkov:skip=CKV_AWS_260: estudo — HTTP público (porta 80) é o objetivo do web server de exemplo
  # checkov:skip=CKV_AWS_382: estudo — egress aberto é o padrão do laboratório
  # checkov:skip=CKV_AWS_23: estudo — descrição por regra dispensável neste módulo didático

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
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

  tags = merge(local.tags, { Name = "ec2-first-instance-sg" })
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  # checkov:skip=CKV2_AWS_41: estudo — instância de demonstração sem IAM role anexada
  # checkov:skip=CKV_AWS_126: estudo — monitoramento detalhado gera custo desnecessário
  # checkov:skip=CKV_AWS_135: estudo — EBS optimized desnecessário para instância de classe pequena

  # Hardening: exige IMDSv2 (CKV_AWS_79) e criptografa o volume root (CKV_AWS_8)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Terraform - AWS Certification Portfolio</h1>" > /var/www/html/index.html
  EOF

  tags = merge(local.tags, { Name = "ec2-first-instance" })
}
