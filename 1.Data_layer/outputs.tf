# Output for Mumbai RDS Primary Instance Endpoint
output "mumbai_rds_instance_endpoint" {
  description = "The endpoint of the Mumbai primary RDS instance"
  value       = aws_db_instance.mumbai_rds_instance.endpoint
}

# Output for Mumbai RDS Read Replica Endpoint
output "mumbai_rds_read_replica_endpoint" {
  description = "The endpoint of the Mumbai read replica RDS instance"
  value       = aws_db_instance.mumbai_rds_read_replica.endpoint
}

# Output for Virginia RDS Read Replica Endpoint
output "virginia_rds_read_replica_endpoint" {
  description = "The endpoint of the Virginia read replica RDS instance"
  value       = aws_db_instance.virginia_rds_read_replica.endpoint
}
