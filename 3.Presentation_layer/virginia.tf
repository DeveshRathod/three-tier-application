resource "aws_vpc" "virginia_vpc" {
  provider   = aws.virginia
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "VirginiaVPC"
  }
}

resource "aws_subnet" "virginia_subnet" {
  provider          = aws.virginia
  vpc_id            = aws_vpc.virginia_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "VirginiaSubnet"
  }
}

resource "aws_internet_gateway" "virginia_igw" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia_vpc.id
  tags = {
    Name = "VirginiaIGW"
  }
}

resource "aws_route_table" "virginia_rt" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia_vpc.id
  tags = {
    Name = "VirginiaRouteTable"
  }
}

resource "aws_route" "virginia_internet_route" {
  provider               = aws.virginia
  route_table_id         = aws_route_table.virginia_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.virginia_igw.id
}

resource "aws_route_table_association" "virginia_rt_assoc" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.virginia_subnet.id
  route_table_id = aws_route_table.virginia_rt.id
}

resource "aws_security_group" "virginia_sg" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia_vpc.id
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
    Name = "VirginiaSG"
  }
}

resource "aws_instance" "virginia_instance" {
  provider                    = aws.virginia
  ami                         = var.ami_virginia
  instance_type               = var.instance_type
  key_name                    = var.key_virginia
  subnet_id                   = aws_subnet.virginia_subnet.id
  security_groups             = [aws_security_group.virginia_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.frontend_profile.name
  user_data                   = file("${path.module}/script2.sh")
  tags = {
    Name = "VirginiaInstance"
  }

  # Explicitly specify depends_on for clarity
  depends_on = [
    aws_s3_bucket.virginia_bucket,
  ]
}

resource "aws_s3_bucket" "virginia_bucket" {
  provider = aws.virginia
  bucket   = "devesh11411virginia"

  tags = {
    Name        = "DeveshVirginiaBucket"
    Environment = "Development"
  }
}
