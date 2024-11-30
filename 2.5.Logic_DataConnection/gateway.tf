#######
# TGWs
#######

# Mumbai Transit Gateway
resource "aws_ec2_transit_gateway" "tgw_mumbai" {
  provider    = aws.mumbai
  description = "Transit Gateway for inter-region VPC communication in Mumbai"
  dns_support = "enable"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "main-transit-gateway-mumbai"
  }
}

# Virginia Transit Gateway
resource "aws_ec2_transit_gateway" "tgw_virginia" {
  provider    = aws.virginia
  description = "Transit Gateway for inter-region VPC communication in Virginia"
  dns_support = "enable"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "main-transit-gateway-virginia"
  }
}

#########
# Peering
#########

# Mumbai to Virginia Peering Attachment
resource "aws_ec2_transit_gateway_peering_attachment" "peering_attachment" {
  provider                = aws.mumbai
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_mumbai.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_virginia.id
  peer_region             = "us-east-1"

  tags = {
    Name = "tgw-peering-mumbai-to-virginia"
  }

  depends_on = [
    aws_ec2_transit_gateway.tgw_mumbai,
    aws_ec2_transit_gateway.tgw_virginia,
  ]
}

# Peering Attachment Accepter in Virginia
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "accept_peering_attachment" {
  provider                      = aws.virginia
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.peering_attachment.id

  tags = {
    Name = "accept-peering-attachment-virginia"
  }

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.peering_attachment
  ]
}


#################
# Route Table TGW
#################

# Route Table for Mumbai Transit Gateway
resource "aws_ec2_transit_gateway_route_table" "tgw_mumbai_rt" {
  provider           = aws.mumbai
  transit_gateway_id = aws_ec2_transit_gateway.tgw_mumbai.id

  tags = {
    Name = "tgw-route-table-mumbai"
  }

  depends_on = [aws_ec2_transit_gateway.tgw_mumbai]
}

# Route Table for Virginia Transit Gateway
resource "aws_ec2_transit_gateway_route_table" "tgw_virginia_rt" {
  provider           = aws.virginia
  transit_gateway_id = aws_ec2_transit_gateway.tgw_virginia.id

  tags = {
    Name = "tgw-route-table-virginia"
  }

  depends_on = [aws_ec2_transit_gateway.tgw_virginia]
}

##################
# VPC Attachments
##################

# Mumbai TG Attachment for Server VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "server_mumbai_attachment" {
  provider                                        = aws.mumbai
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw_mumbai.id
  vpc_id                                          = var.server_mumbai_vpc_id
  subnet_ids                                      = var.server_mumbai_subnet_ids
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false
  dns_support                                     = "enable"

  tags = {
    Name = "server-mumbai-attachment"
  }

  depends_on = [
    aws_ec2_transit_gateway.tgw_mumbai
  ]
}

# Virginia TG Attachment for Server VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "server_virginia_attachment" {
  provider                                        = aws.virginia
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw_virginia.id
  vpc_id                                          = var.server_virginia_vpc_id
  subnet_ids                                      = var.server_virginia_subnet_ids
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false
  dns_support                                     = "enable"

  tags = {
    Name = "server-virginia-attachment"
  }

  depends_on = [
    aws_ec2_transit_gateway.tgw_virginia
  ]
}

# Mumbai TG Attachment for Database VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "db_mumbai_attachment" {
  provider                                        = aws.mumbai
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw_mumbai.id
  vpc_id                                          = var.mumbai_db_vpc_id
  subnet_ids                                      = var.mumbai_db_subnet_ids
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false
  dns_support                                     = "enable"

  tags = {
    Name = "db-mumbai-attachment"
  }

  depends_on = [
    aws_ec2_transit_gateway.tgw_mumbai
  ]
}

# Virginia TG Attachment for Database VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "db_virginia_attachment" {
  provider                                        = aws.virginia
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw_virginia.id
  vpc_id                                          = var.virginia_db_vpc_id
  subnet_ids                                      = var.virginia_db_subnet_ids
  transit_gateway_default_route_table_propagation = false
  transit_gateway_default_route_table_association = false
  dns_support                                     = "enable"

  tags = {
    Name = "db-virginia-attachment"
  }

  depends_on = [
    aws_ec2_transit_gateway.tgw_virginia
  ]
}


#############
# Association
#############

resource "aws_ec2_transit_gateway_route_table_association" "tgw_mumbai_rt_peering_association" {
  provider                       = aws.mumbai
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_mumbai_rt.id

  depends_on = [aws_ec2_transit_gateway_route_table.tgw_mumbai_rt, aws_ec2_transit_gateway_peering_attachment_accepter.accept_peering_attachment]
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_virginia_rt_peering_association" {
  provider                       = aws.virginia
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_virginia_rt.id

  depends_on = [aws_ec2_transit_gateway_route_table.tgw_virginia_rt, aws_ec2_transit_gateway_peering_attachment_accepter.accept_peering_attachment]
}

# Association for Database Route Table in Mumbai
resource "aws_ec2_transit_gateway_route_table_association" "tgw_mumbai_rt_db_association" {
  provider                       = aws.mumbai
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.db_mumbai_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_mumbai_rt.id

  depends_on = [aws_ec2_transit_gateway_route_table.tgw_mumbai_rt, aws_ec2_transit_gateway_vpc_attachment.db_mumbai_attachment]
}

# Association for Server Route Table in Mumbai
resource "aws_ec2_transit_gateway_route_table_association" "tgw_mumbai_rt_server_association" {
  provider                       = aws.mumbai
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.server_mumbai_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_mumbai_rt.id

  depends_on = [aws_ec2_transit_gateway_route_table.tgw_mumbai_rt, aws_ec2_transit_gateway_vpc_attachment.server_mumbai_attachment]
}

# Association for Database Route Table in Virginia
resource "aws_ec2_transit_gateway_route_table_association" "tgw_virginia_rt_db_association" {
  provider                       = aws.virginia
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.db_virginia_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_virginia_rt.id

  depends_on = [aws_ec2_transit_gateway_route_table.tgw_virginia_rt, aws_ec2_transit_gateway_vpc_attachment.db_virginia_attachment]
}

# Association for Server Route Table in Virginia
resource "aws_ec2_transit_gateway_route_table_association" "tgw_virginia_rt_server_association" {
  provider                       = aws.virginia
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.server_virginia_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_virginia_rt.id

  depends_on = [aws_ec2_transit_gateway_route_table.tgw_virginia_rt, aws_ec2_transit_gateway_vpc_attachment.server_virginia_attachment]
}


##################
# TGW Level Routes
##################

# Fetch CIDR Block for Mumbai Server VPC
data "aws_vpc" "server_mumbai_vpc" {
  id = var.server_mumbai_vpc_id
}

# Fetch CIDR Block for Mumbai Database VPC
data "aws_vpc" "mumbai_db_vpc" {
  id = var.mumbai_db_vpc_id
}

# Fetch CIDR Block for Virginia Server VPC
data "aws_vpc" "server_virginia_vpc" {
  id = var.server_virginia_vpc_id
}

# Fetch CIDR Block for Virginia Database VPC
data "aws_vpc" "virginia_db_vpc" {
  id = var.virginia_db_vpc_id
}

# Mumbai Server to Mumbai Database Route
resource "aws_ec2_transit_gateway_route" "mumbai_server_to_mumbai_db" {
  provider                       = aws.mumbai
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_mumbai_rt.id
  destination_cidr_block         = data.aws_vpc.mumbai_db_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.db_mumbai_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.db_mumbai_attachment,
    aws_ec2_transit_gateway_route_table.tgw_mumbai_rt,
  ]
}

# Mumbai Database to Mumbai Server Route
resource "aws_ec2_transit_gateway_route" "mumbai_db_to_mumbai_server" {
  provider                       = aws.mumbai
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_mumbai_rt.id
  destination_cidr_block         = data.aws_vpc.server_mumbai_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.server_mumbai_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.server_mumbai_attachment,
    aws_ec2_transit_gateway_route_table.tgw_mumbai_rt,
  ]
}

# Virginia Server to Virginia Database Route
resource "aws_ec2_transit_gateway_route" "virginia_server_to_virginia_db" {
  provider                       = aws.virginia
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_virginia_rt.id
  destination_cidr_block         = data.aws_vpc.virginia_db_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.db_virginia_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.db_virginia_attachment,
    aws_ec2_transit_gateway_route_table.tgw_virginia_rt,
  ]
}

# Virginia Database to Virginia Server Route
resource "aws_ec2_transit_gateway_route" "virginia_db_to_virginia_server" {
  provider                       = aws.virginia
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_virginia_rt.id
  destination_cidr_block         = data.aws_vpc.server_virginia_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.server_virginia_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.server_virginia_attachment,
    aws_ec2_transit_gateway_route_table.tgw_virginia_rt,
  ]
}

#####################
# Cross-Region Routes
#####################

# Mumbai Server to Virginia Database Route
resource "aws_ec2_transit_gateway_route" "mumbai_server_to_virginia_db" {
  provider                       = aws.mumbai
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_mumbai_rt.id
  destination_cidr_block         = data.aws_vpc.virginia_db_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.server_mumbai_attachment,
    aws_ec2_transit_gateway_peering_attachment_accepter.accept_peering_attachment,
    aws_ec2_transit_gateway_route_table.tgw_mumbai_rt,
  ]
}

# Virginia Database to Mumbai Server Route
resource "aws_ec2_transit_gateway_route" "virginia_db_to_mumbai_server" {
  provider                       = aws.virginia
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_virginia_rt.id
  destination_cidr_block         = data.aws_vpc.server_mumbai_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.db_virginia_attachment,
    aws_ec2_transit_gateway_peering_attachment_accepter.accept_peering_attachment,
    aws_ec2_transit_gateway_route_table.tgw_virginia_rt,
  ]
}

# Virginia Server to Mumbai Database Route
resource "aws_ec2_transit_gateway_route" "virginia_server_to_mumbai_db" {
  provider                       = aws.virginia
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_virginia_rt.id
  destination_cidr_block         = data.aws_vpc.mumbai_db_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.server_virginia_attachment,
    aws_ec2_transit_gateway_peering_attachment_accepter.accept_peering_attachment,
    aws_ec2_transit_gateway_route_table.tgw_virginia_rt,
  ]
}

# Mumbai Database to Virginia Server Route
resource "aws_ec2_transit_gateway_route" "mumbai_db_to_virginia_server" {
  provider                       = aws.mumbai
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_mumbai_rt.id
  destination_cidr_block         = data.aws_vpc.server_virginia_vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering_attachment.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.db_mumbai_attachment,
    aws_ec2_transit_gateway_peering_attachment_accepter.accept_peering_attachment,
    aws_ec2_transit_gateway_route_table.tgw_mumbai_rt,
  ]
}

##################
# VPC Level Routes
##################

# Adding routes to the existing Mumbai Server Route Table
resource "aws_route" "mumbai_server_to_mumbai_db" {
  provider               = aws.mumbai
  route_table_id         = var.server_mumbai_route_table_id
  destination_cidr_block = data.aws_vpc.mumbai_db_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_mumbai.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_mumbai
  ]
}

resource "aws_route" "mumbai_server_to_virginia_db" {
  provider               = aws.mumbai
  route_table_id         = var.server_mumbai_route_table_id
  destination_cidr_block = data.aws_vpc.virginia_db_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_mumbai.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_mumbai
  ]
}

# Adding routes to the existing Virginia Server Route Table
resource "aws_route" "virginia_server_to_virginia_db" {
  provider               = aws.virginia
  route_table_id         = var.server_virginia_route_table_id
  destination_cidr_block = data.aws_vpc.virginia_db_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_virginia.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_virginia
  ]
}

resource "aws_route" "virginia_server_to_mumbai_db" {
  provider               = aws.virginia
  route_table_id         = var.server_virginia_route_table_id
  destination_cidr_block = data.aws_vpc.mumbai_db_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_virginia.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_virginia
  ]
}

# Adding routes to the existing Mumbai DB Route Table
resource "aws_route" "mumbai_db_to_mumbai_server" {
  provider               = aws.mumbai
  route_table_id         = var.mumbai_db_route_table_id
  destination_cidr_block = data.aws_vpc.server_mumbai_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_mumbai.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_mumbai
  ]
}

resource "aws_route" "mumbai_db_to_virginia_server" {
  provider               = aws.mumbai
  route_table_id         = var.mumbai_db_route_table_id
  destination_cidr_block = data.aws_vpc.server_virginia_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_mumbai.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_mumbai
  ]
}

# Adding routes to the existing Virginia DB Route Table
resource "aws_route" "virginia_db_to_virginia_server" {
  provider               = aws.virginia
  route_table_id         = var.virginia_db_route_table_id
  destination_cidr_block = data.aws_vpc.server_virginia_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_virginia.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_virginia
  ]
}

resource "aws_route" "virginia_db_to_mumbai_server" {
  provider               = aws.virginia
  route_table_id         = var.virginia_db_route_table_id
  destination_cidr_block = data.aws_vpc.server_mumbai_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_virginia.id

  depends_on = [
    aws_ec2_transit_gateway.tgw_virginia
  ]
}
