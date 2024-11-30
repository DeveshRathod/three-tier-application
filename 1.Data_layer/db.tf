# # Mumbai DB Subnet Group (Private)
resource "aws_db_subnet_group" "mumbai_db_subnet_group" {
  provider = aws.mumbai
  name     = "mumbai_db_subnet_group"
  subnet_ids = [
    aws_subnet.mumbai_db_subnet_a.id,
    aws_subnet.mumbai_db_subnet_b.id,
  ]
  tags = {
    Name = "mumbai-db-subnet-group"
  }

  depends_on = [aws_subnet.mumbai_db_subnet_a, aws_subnet.mumbai_db_subnet_b]
}

# Virginia DB Subnet Group (Private)
resource "aws_db_subnet_group" "virginia_db_subnet_group" {
  provider = aws.virginia
  name     = "virginia_db_subnet_group"
  subnet_ids = [
    aws_subnet.virginia_db_subnet_a.id,
    aws_subnet.virginia_db_subnet_b.id,
  ]
  tags = {
    Name = "virginia-db-subnet-group"
  }

  depends_on = [aws_subnet.virginia_db_subnet_a, aws_subnet.virginia_db_subnet_b]
}

# Mumbai RDS Primary Instance (Private)
resource "aws_db_instance" "mumbai_rds_instance" {
  provider               = aws.mumbai
  identifier             = "mumbai-primary-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.mumbai_db_subnet_group.name
  db_name                = "<DB_NAME>"
  username               = "<DB_USERNAME>"
  password               = "<DB_PASSWORD>"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.mumbai_db_sg.id]

  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = {
    Name = "mumbai-primary-db"
  }

  depends_on = [
    aws_db_subnet_group.mumbai_db_subnet_group,
    aws_security_group.mumbai_db_sg
  ]
}

# Mumbai RDS Read Replica in Different AZ (Private)
resource "aws_db_instance" "mumbai_rds_read_replica" {
  provider               = aws.mumbai
  identifier             = "mumbai-read-replica"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  publicly_accessible    = false
  replicate_source_db    = aws_db_instance.mumbai_rds_instance.arn
  availability_zone      = "ap-south-1b"
  db_subnet_group_name   = aws_db_subnet_group.mumbai_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.mumbai_db_sg.id]

  skip_final_snapshot = true

  tags = {
    Name = "mumbai-read-replica"
  }

  depends_on = [
    aws_db_subnet_group.mumbai_db_subnet_group,
    aws_db_instance.mumbai_rds_instance,
    aws_security_group.mumbai_db_sg
  ]
}

# Virginia RDS Read Replica (Cross-Region, Private)
resource "aws_db_instance" "virginia_rds_read_replica" {
  provider               = aws.virginia
  identifier             = "virginia-read-replica"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  publicly_accessible    = false
  replicate_source_db    = aws_db_instance.mumbai_rds_instance.arn
  db_subnet_group_name   = aws_db_subnet_group.virginia_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.virginia_db_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "virginia-read-replica"
  }

  depends_on = [
    aws_db_instance.mumbai_rds_instance,
    aws_db_subnet_group.virginia_db_subnet_group,
    aws_security_group.virginia_db_sg
  ]
}
