# Mumbai VPC for Database
resource "aws_vpc" "mumbai_db_vpc" {
  provider             = aws.mumbai
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-mumbai-db"
  }
}

# Virginia VPC for Database
resource "aws_vpc" "virginia_db_vpc" {
  provider             = aws.virginia
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-virginia-db"
  }
}

# Mumbai Private Subnets for Database
resource "aws_subnet" "mumbai_db_subnet_a" {
  provider                = aws.mumbai
  vpc_id                  = aws_vpc.mumbai_db_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

  depends_on = [aws_vpc.mumbai_db_vpc]

  tags = {
    Name = "subnet-mumbai-db-private-a"
  }
}

resource "aws_subnet" "mumbai_db_subnet_b" {
  provider                = aws.mumbai
  vpc_id                  = aws_vpc.mumbai_db_vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  depends_on = [aws_vpc.mumbai_db_vpc]
  tags = {
    Name = "subnet-mumbai-db-private-b"
  }
}

# Virginia Private Subnets for Database
resource "aws_subnet" "virginia_db_subnet_a" {
  provider                = aws.virginia
  vpc_id                  = aws_vpc.virginia_db_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  depends_on = [aws_vpc.virginia_db_vpc]

  tags = {
    Name = "subnet-virginia-db-private-a"
  }
}

resource "aws_subnet" "virginia_db_subnet_b" {
  provider                = aws.virginia
  vpc_id                  = aws_vpc.virginia_db_vpc.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  depends_on = [aws_vpc.virginia_db_vpc]

  tags = {
    Name = "subnet-virginia-db-private-b"
  }
}

# Mumbai Route Table for Database Private Subnets
resource "aws_route_table" "mumbai_db_rt_private" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai_db_vpc.id

  depends_on = [aws_vpc.mumbai_db_vpc]

  tags = {
    Name = "rt-mumbai-db-private"
  }
}

# Virginia Route Table for Database Private Subnets
resource "aws_route_table" "virginia_db_rt_private" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia_db_vpc.id

  depends_on = [aws_vpc.virginia_db_vpc]

  tags = {
    Name = "rt-virginia-db-private"
  }
}

# Associate Mumbai Database Subnets with Route Table
resource "aws_route_table_association" "mumbai_db_subnet_a_rta" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.mumbai_db_subnet_a.id
  route_table_id = aws_route_table.mumbai_db_rt_private.id

  depends_on = [
    aws_subnet.mumbai_db_subnet_a,
    aws_route_table.mumbai_db_rt_private,
  ]
}

resource "aws_route_table_association" "mumbai_db_subnet_b_rta" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.mumbai_db_subnet_b.id
  route_table_id = aws_route_table.mumbai_db_rt_private.id

  depends_on = [
    aws_subnet.mumbai_db_subnet_b,
    aws_route_table.mumbai_db_rt_private,
  ]
}

# Associate Virginia Database Subnets with Route Table
resource "aws_route_table_association" "virginia_db_subnet_a_rta" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.virginia_db_subnet_a.id
  route_table_id = aws_route_table.virginia_db_rt_private.id

  depends_on = [
    aws_subnet.virginia_db_subnet_a,
    aws_route_table.virginia_db_rt_private,
  ]
}

resource "aws_route_table_association" "virginia_db_subnet_b_rta" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.virginia_db_subnet_b.id
  route_table_id = aws_route_table.virginia_db_rt_private.id

  depends_on = [
    aws_subnet.virginia_db_subnet_b,
    aws_route_table.virginia_db_rt_private,
  ]
}


# Security Group for the Database in Mumbai
resource "aws_security_group" "mumbai_db_sg" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.mumbai_db_vpc.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.server_mumbai_vpc.cidr_block,
      aws_vpc.server_virginia_vpc.cidr_block,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-mumbai-db"
  }

  depends_on = [aws_vpc.server_mumbai_vpc, aws_vpc.server_virginia_vpc, aws_vpc.virginia_db_vpc]
}

# Security Group for the Database in Virginia
resource "aws_security_group" "virginia_db_sg" {
  provider = aws.virginia
  vpc_id   = aws_vpc.virginia_db_vpc.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.server_mumbai_vpc.cidr_block,
      aws_vpc.server_virginia_vpc.cidr_block,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "sg-virginia-db"
  }

  depends_on = [aws_vpc.server_mumbai_vpc, aws_vpc.server_virginia_vpc, aws_vpc.mumbai_db_vpc]
}
