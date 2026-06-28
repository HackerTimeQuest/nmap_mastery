provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for deployment"
  default     = "us-east-1"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for lab target"
  default     = "t3.micro"
  type        = string
}

resource "aws_security_group" "lab_sg" {
  name        = "nmap-mastery-lab"
  description = "Allow inbound nmap scanning from attacker subnet"

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "target" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.lab.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  user_data              = base64encode(file("${path.module}/../cloud-init/99-ansible.sh"))

  tags = {
    Name      = "nmap-mastery-target"
    Environment = "lab"
    Lab       = "nmap_mastery"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "hacker-time-lab" }
}

resource "aws_subnet" "lab" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = { Name = "lab-subnet" }
}

output "target_ip" {
  value = aws_instance.target.private_ip
  description = "Private IP of the target server"
}
