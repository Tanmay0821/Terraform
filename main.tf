#create vpc
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  region = "ap-south-1"

  tags = {
    Name = var.vpc_name
  }
}

#create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = resource.aws_vpc.main.id
  cidr_block = var.pub_subnet_cidr
  region = "ap-south-1"

  tags = {
    Name = "tanmay_public_subnet"
  }
}

#create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = resource.aws_vpc.main.id
  cidr_block = var.pvt_subnet_cidr
  region = "ap-south-1"

  tags = {
    Name = "tanmay_private_subnet"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = resource.aws_vpc.main.id
    region = "ap-south-1"

  tags = {
    Name = "public_igw"
  }
}

# Creating Public Route Table
resource "aws_route_table" "pub_route" {
  vpc_id =  resource.aws_vpc.main.id
    region = "ap-south-1"
  

  tags = {
    Name = "public_route"
  }
}

# Creating Private Route Table
resource "aws_route_table" "pri_route" {
  vpc_id =  resource.aws_vpc.main.id
    region = "ap-south-1"

  tags = {
    Name = "private_route"
  }
}

# Internet Route for Public Subnet
resource "aws_route" "public_internet_route" {
  route_table_id         = resource.aws_route_table.pub_route.id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = resource.aws_internet_gateway.igw.id
    region = "ap-south-1"
  depends_on = [aws_internet_gateway.igw]
}

# Associating Subnets with Route Tables
resource "aws_route_table_association" "pub_subnet_association" {
  subnet_id      = resource.aws_subnet.public_subnet.id
  route_table_id = resource.aws_route_table.pub_route.id
    region = "ap-south-1"
}

resource "aws_route_table_association" "pri_subnet_association" {
  subnet_id      = resource.aws_subnet.private_subnet.id
  route_table_id =resource.aws_route_table.pri_route.id
    region = "ap-south-1"
}

# Creating Security Group for EC2 Instance
resource "aws_security_group" "EC2_SG" {
  vpc_id      =resource.aws_vpc.main.id
  name        = "ec2-security-group"
  description = "Allow SSH inbound traffic"
    region = "ap-south-1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
  description = "Allow HTTP traffic"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2_SG"
  }
}

# Launch EC2 Instance in Public Subnet
resource "aws_instance" "my_ec2" {
  ami                    =  "ami-01760eea5c574eb86" # Example: Amazon Linux 2 in ap-south-1, change per your region
  instance_type          = "t3.micro"
  key_name               = "gav-05"
  region                 = "ap-south-1"
  subnet_id              = resource.aws_subnet.public_subnet.id
  vpc_security_group_ids = [resource.aws_security_group.EC2_SG.id]
  associate_public_ip_address = true
  
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install nginx -y
                systemctl enable nginx
                systemctl start nginx
                EOF

  tags = {
    Name = "tanmay-EC2"
  }
}
