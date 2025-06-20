provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create a new VPC
resource "aws_vpc" "custom" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom-service-mesh-vpc"
  }
}

# Create a new subnet in the custom VPC
resource "aws_subnet" "custom" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "custom-service-mesh-subnet"
  }
}

# Update the security group to use the custom VPC
resource "aws_security_group" "demo" {
  name        = "service-mesh-demo-sg"
  description = "Allow HTTP and Consul"
  vpc_id      = aws_vpc.custom.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
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

# Create an Internet Gateway
resource "aws_internet_gateway" "custom" {
  vpc_id = aws_vpc.custom.id
  tags = {
    Name = "custom-igw"
  }
}

# Create a route table
resource "aws_route_table" "custom" {
  vpc_id = aws_vpc.custom.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom.id
  }
  tags = {
    Name = "custom-public-rt"
  }
}

# Associate the route table with your subnet
resource "aws_route_table_association" "custom" {
  subnet_id      = aws_subnet.custom.id
  route_table_id = aws_route_table.custom.id
}

# Fetch availability zones for the region
data "aws_availability_zones" "available" {}

resource "aws_instance" "demo" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.demo.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data              = data.template_file.user_data.rendered
  subnet_id              = aws_subnet.custom.id
  tags = {
    Name = "service-mesh-demo"
  }
}

resource "aws_key_pair" "default" {
  count      = var.public_key_path != "" ? 1 : 0
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  vars = {
    repo_url = var.repo_url
  }
}

resource "aws_secretsmanager_secret" "github_pat" {
  name = "github_pat20"
}

resource "aws_secretsmanager_secret_version" "github_pat_version" {
  secret_id     = aws_secretsmanager_secret.github_pat.id
  secret_string = var.github_pat
}

# IAM policy for EC2 to access the secret
data "aws_iam_policy_document" "ec2_secrets_access" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.github_pat.arn]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_secrets_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ec2_secrets_policy" {
  name   = "ec2_secrets_policy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_secrets_access.json
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}