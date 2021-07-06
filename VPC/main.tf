provider "aws" {
  region = "us-east-1"
 }

#create VPC
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Dev"
  }
}
#create Internet Gateway
resource "aws_internet_gateway" "dev_ig" {
  vpc_id = aws_vpc.dev.id
tags = {
  Name ="dev-IG"
}
}


#create Route Table
resource "aws_route_table" "dev_ig_route" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_ig.id
  }
  tags = {
    Name = "dev_ig_route"
  }
}
#create Subnet
resource "aws_subnet" "dev_private" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.dev.id
}
resource "aws_subnet" "dev_public" {
cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.dev.id
}

#create route table association with  subnet
resource "aws_route_table_association" "dev_ig_private" {
  subnet_id = aws_subnet.dev_public.id
  route_table_id = aws_route_table.dev_ig_route.id
}
resource "aws_route_table_association" "dev_ig_public" {
  subnet_id = aws_subnet.dev_private.id
  route_table_id = aws_route_table.dev_ig_route.id
}

#create security group
resource "aws_security_group" "dev_sec" {
  name = "dev_security_group"
  vpc_id = aws_vpc.dev.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#create Instance
resource "aws_instance" "dev_ins_01" {
  ami = "ami-0ab4d1e9cf9a1215a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.dev_private.id
  security_groups = [aws_security_group.dev_sec.id]
  key_name = "Aws_My_Key01"
  tags = {
    Name = "dev01"
  }
}
resource "aws_instance" "dev_ins_02" {
  ami = "ami-0ab4d1e9cf9a1215a"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.dev_public.id
  security_groups = [aws_security_group.dev_sec.id]
  associate_public_ip_address = "true"
  key_name = "Aws_My_Key01"
  tags = {
    Name = "dev02"
  }
}

output "public_ip_dev2" {
  value = aws_instance.dev_ins_02.public_ip
}
