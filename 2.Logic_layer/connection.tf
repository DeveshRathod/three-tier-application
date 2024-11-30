### Mumbai Configuration ###

# Internet Gateway for Mumbai VPC
resource "aws_internet_gateway" "mumbai_ig" {
  vpc_id   = aws_vpc.mumbai.id
  provider = aws.mumbai

  tags = {
    Name = "mumbai-ig"
  }
}

# NAT Gateway for Mumbai Private Subnets
resource "aws_eip" "mumbai_nat_eip" {
  provider = aws.mumbai
}

resource "aws_nat_gateway" "mumbai_nat_gateway" {
  provider      = aws.mumbai
  allocation_id = aws_eip.mumbai_nat_eip.id
  subnet_id     = aws_subnet.public_mumbai_1.id
}

# Route Table for Mumbai Public Subnets
resource "aws_route_table" "mumbai_public_rt" {
  vpc_id   = aws_vpc.mumbai.id
  provider = aws.mumbai

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai_ig.id
  }

  tags = {
    Name = "mumbai-public-rt"
  }
}

# Associate Route Table with Mumbai Public Subnets
resource "aws_route_table_association" "public_mumbai_1_rt" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.public_mumbai_1.id
  route_table_id = aws_route_table.mumbai_public_rt.id
}

resource "aws_route_table_association" "public_mumbai_2_rt" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.public_mumbai_2.id
  route_table_id = aws_route_table.mumbai_public_rt.id
}

# Route Table for Mumbai Private Subnets (Using single NAT Gateway)
resource "aws_route_table" "mumbai_private_rt" {
  vpc_id   = aws_vpc.mumbai.id
  provider = aws.mumbai

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mumbai_nat_gateway.id
  }

  tags = {
    Name = "mumbai-private-rt"
  }
}

# Associate Route Table with Mumbai Private Subnets
resource "aws_route_table_association" "private_mumbai_1_rt_assoc" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.private_mumbai_1.id
  route_table_id = aws_route_table.mumbai_private_rt.id
}

resource "aws_route_table_association" "private_mumbai_2_rt_assoc" {
  provider       = aws.mumbai
  subnet_id      = aws_subnet.private_mumbai_2.id
  route_table_id = aws_route_table.mumbai_private_rt.id
}


### Virginia (us-east-1) Configuration ###

# Internet Gateway for Virginia VPC
resource "aws_internet_gateway" "virginia_ig" {
  vpc_id   = aws_vpc.virginia.id
  provider = aws.virginia

  tags = {
    Name = "virginia-ig"
  }
}

# NAT Gateway for Virginia Private Subnets
resource "aws_eip" "virginia_nat_eip" {
  provider = aws.virginia
}

resource "aws_nat_gateway" "virginia_nat_gateway" {
  provider      = aws.virginia
  allocation_id = aws_eip.virginia_nat_eip.id
  subnet_id     = aws_subnet.public_virginia_1.id
}

# Route Table for Virginia Public Subnets
resource "aws_route_table" "virginia_public_rt" {
  vpc_id   = aws_vpc.virginia.id
  provider = aws.virginia

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.virginia_ig.id
  }

  tags = {
    Name = "virginia-public-rt"
  }
}

# Associate Route Table with Virginia Public Subnets
resource "aws_route_table_association" "public_virginia_1_rt" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.public_virginia_1.id
  route_table_id = aws_route_table.virginia_public_rt.id
}

resource "aws_route_table_association" "public_virginia_2_rt" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.public_virginia_2.id
  route_table_id = aws_route_table.virginia_public_rt.id
}

# Route Table for Virginia Private Subnets (Using single NAT Gateway)
resource "aws_route_table" "virginia_private_rt" {
  vpc_id   = aws_vpc.virginia.id
  provider = aws.virginia

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.virginia_nat_gateway.id
  }

  tags = {
    Name = "virginia-private-rt"
  }
}

# Associate Route Table with Virginia Private Subnets
resource "aws_route_table_association" "private_virginia_1_rt_assoc" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.private_virginia_1.id
  route_table_id = aws_route_table.virginia_private_rt.id
}

resource "aws_route_table_association" "private_virginia_2_rt_assoc" {
  provider       = aws.virginia
  subnet_id      = aws_subnet.private_virginia_2.id
  route_table_id = aws_route_table.virginia_private_rt.id
}
