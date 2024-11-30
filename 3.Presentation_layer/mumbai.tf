resource "aws_vpc" "mumbai_vpc" {
  provider   = aws.mumbai
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MumbaiVPC"
  }
}

resource "aws_subnet" "mumbai_subnet" {
  provider          = aws.mumbai
  vpc_id            = aws_vpc.mumbai_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "MumbaiSubnet"
  }
}

resource "aws_internet_gateway" "mumbai_igw" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai_vpc.id
  tags = {
    Name = "MumbaiIGW"
  }
}

resource "aws_route_table" "mumbai_rt" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai_vpc.id
  tags = {
    Name = "MumbaiRouteTable"
  }
}

resource "aws_route" "mumbai_internet_route" {
  provider               = aws.mumbai
  route_table_id         = aws_route_table.mumbai_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mumbai_igw.id
}

resource "aws_route_table_association" "mumbai_rt_assoc" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.mumbai_subnet.id
  route_table_id = aws_route_table.mumbai_rt.id
}

resource "aws_security_group" "mumbai_sg" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  tags = {
    Name = "MumbaiSG"
  }
}

resource "aws_instance" "mumbai_instance" {
  provider                    = aws.mumbai
  ami                         = var.ami_mumbai
  instance_type               = var.instance_type
  key_name                    = var.key_mumbai
  subnet_id                   = aws_subnet.mumbai_subnet.id
  security_groups             = [aws_security_group.mumbai_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.frontend_profile.name
  user_data                   = file("${path.module}/script1.sh")
  tags = {
    Name = "MumbaiInstance"
  }

  depends_on = [
    aws_s3_bucket.mumbai_bucket,
  ]
}

resource "aws_s3_bucket" "mumbai_bucket" {
  provider = aws.mumbai
  bucket   = "devesh11411mumbai"

  tags = {
    Name        = "DeveshMumbaiBucket"
    Environment = "Development"
  }
}
