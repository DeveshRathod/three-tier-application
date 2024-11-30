# VPC for Mumbai (ap-south-1)
resource "aws_vpc" "mumbai" {
  provider   = aws.mumbai
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "mumbai-vpc"
  }
}

resource "aws_vpc" "virginia" {
  provider   = aws.virginia
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "virginia-vpc"
  }
}


resource "aws_subnet" "private_mumbai_1" {
  provider          = aws.mumbai
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.mumbai.id
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-mumbai-subnet-1"
  }
}


resource "aws_subnet" "private_mumbai_2" {
  provider          = aws.mumbai
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.mumbai.id
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-mumbai-subnet-2"
  }
}

resource "aws_subnet" "public_mumbai_1" {
  provider          = aws.mumbai
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.mumbai.id
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-mumbai-subnet-1"
  }
}

resource "aws_subnet" "public_mumbai_2" {
  provider          = aws.mumbai
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.mumbai.id
  availability_zone = "ap-south-1b"

  tags = {
    Name = "public-mumbai-subnet-2"
  }
}


resource "aws_subnet" "private_virginia_1" {
  provider          = aws.virginia
  cidr_block        = "10.1.0.0/24"
  vpc_id            = aws_vpc.virginia.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-virginia-subnet-1"
  }
}

resource "aws_subnet" "private_virginia_2" {
  provider          = aws.virginia
  cidr_block        = "10.1.1.0/24"
  vpc_id            = aws_vpc.virginia.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-virginia-subnet-2"
  }
}


resource "aws_subnet" "public_virginia_1" {
  provider          = aws.virginia
  cidr_block        = "10.1.2.0/24"
  vpc_id            = aws_vpc.virginia.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-virginia-subnet-1"
  }
}

resource "aws_subnet" "public_virginia_2" {
  provider          = aws.virginia
  cidr_block        = "10.1.3.0/24"
  vpc_id            = aws_vpc.virginia.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-virginia-subnet-2"
  }
}



# Security Group for Bastion Host in Mumbai
resource "aws_security_group" "bastion_sg_mumbai" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
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
    Name = "bastion-sg-mumbai"
  }
}

# Security Group for Private EC2 in Mumbai
resource "aws_security_group" "private_ec2_sg_mumbai" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
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
    Name = "private-ec2-sg-mumbai"
  }
}

# Security Group for ALB in Mumbai
resource "aws_security_group" "alb_sg_mumbai" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
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
    Name = "alb-sg-mumbai"
  }
}

# Security Group for Bastion Host in Virginia
resource "aws_security_group" "bastion_sg_virginia" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
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
    Name = "bastion-sg-virginia"
  }
}

# Security Group for Private EC2 in Virginia
resource "aws_security_group" "private_ec2_sg_virginia" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
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
    Name = "private-ec2-sg-virginia"
  }
}

# Security Group for ALB in Virginia
resource "aws_security_group" "alb_sg_virginia" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
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
    Name = "alb-sg-virginia"
  }
}
