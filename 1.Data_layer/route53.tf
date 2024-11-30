# Mumbai Private Hosted Zone
resource "aws_route53_zone" "mumbai_private_zone" {
  name = "mumbai-db.local"
  vpc {
    vpc_id = aws_vpc.mumbai_db_vpc.id
  }

  comment = "Private hosted zone for Mumbai DB"
}

# Virginia Private Hosted Zone
resource "aws_route53_zone" "virginia_private_zone" {
  name = "virginia-db.local"
  vpc {
    vpc_id = aws_vpc.virginia_db_vpc.id
  }

  comment = "Private hosted zone for Virginia DB"
}

# Record for Mumbai Primary DB
resource "aws_route53_record" "mumbai_primary_db" {
  zone_id = aws_route53_zone.mumbai_private_zone.zone_id
  name    = "primary.mumbai-db.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.mumbai_rds_instance.endpoint]
}

# Record for Mumbai Read Replica
resource "aws_route53_record" "mumbai_read_replica" {
  zone_id = aws_route53_zone.mumbai_private_zone.zone_id
  name    = "read-replica.mumbai-db.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.mumbai_rds_read_replica.endpoint]
}

# Record for Virginia Read Replica
resource "aws_route53_record" "virginia_read_replica" {
  zone_id = aws_route53_zone.virginia_private_zone.zone_id
  name    = "read-replica.virginia-db.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.virginia_rds_read_replica.endpoint]
}
