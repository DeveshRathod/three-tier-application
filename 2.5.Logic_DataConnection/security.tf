# Mumbai Server Security Group Rules
resource "aws_security_group_rule" "mumbai_server_ingress_db" {
  provider          = aws.mumbai
  security_group_id = var.server_mumbai_sg_id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.mumbai_db_vpc.cidr_block, data.aws_vpc.virginia_db_vpc.cidr_block]
}

resource "aws_security_group_rule" "mumbai_server_ingress_ssh" {
  provider          = aws.mumbai
  security_group_id = var.server_mumbai_sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mumbai_server_ingress_application" {
  provider          = aws.mumbai
  security_group_id = var.server_mumbai_sg_id
  type              = "ingress"
  from_port         = 3000
  to_port           = 10000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mumbai_server_egress" {
  provider          = aws.mumbai
  security_group_id = var.server_mumbai_sg_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Virginia Server Security Group Rules
resource "aws_security_group_rule" "virginia_server_ingress_db" {
  provider          = aws.virginia
  security_group_id = var.server_virginia_sg_id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.mumbai_db_vpc.cidr_block, data.aws_vpc.virginia_db_vpc.cidr_block]
}

resource "aws_security_group_rule" "virginia_server_ingress_ssh" {
  provider          = aws.virginia
  security_group_id = var.server_virginia_sg_id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "virginia_server_ingress_application" {
  provider          = aws.virginia
  security_group_id = var.server_virginia_sg_id
  type              = "ingress"
  from_port         = 3000
  to_port           = 10000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "virginia_server_egress" {
  provider          = aws.virginia
  security_group_id = var.server_virginia_sg_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Mumbai Database Security Group Rules
resource "aws_security_group_rule" "mumbai_db_ingress" {
  provider          = aws.mumbai
  security_group_id = var.mumbai_db_sg_id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.server_mumbai_vpc.cidr_block, data.aws_vpc.server_virginia_vpc.cidr_block]
}

resource "aws_security_group_rule" "mumbai_db_egress" {
  provider          = aws.mumbai
  security_group_id = var.mumbai_db_sg_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Virginia Database Security Group Rules
resource "aws_security_group_rule" "virginia_db_ingress" {
  provider          = aws.virginia
  security_group_id = var.virginia_db_sg_id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.server_mumbai_vpc.cidr_block, data.aws_vpc.server_virginia_vpc.cidr_block]
}

resource "aws_security_group_rule" "virginia_db_egress" {
  provider          = aws.virginia
  security_group_id = var.virginia_db_sg_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
