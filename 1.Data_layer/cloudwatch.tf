# # Mumbai Health Log Group
# resource "aws_cloudwatch_log_group" "mumbai_health_log_group" {
#   name              = "/ec2/mysql-health/mumbai"
#   retention_in_days = 7

#   depends_on = [
#     aws_instance.server_mumbai_ec2
#   ]
# }

# # Mumbai Health Log Stream
# resource "aws_cloudwatch_log_stream" "mumbai_health_log_stream" {
#   log_group_name = aws_cloudwatch_log_group.mumbai_health_log_group.name
#   name           = "mumbai-health-log-stream"

#   depends_on = [
#     aws_cloudwatch_log_group.mumbai_health_log_group,
#     aws_instance.server_mumbai_ec2
#   ]
# }

# # Virginia Health Log Group
# resource "aws_cloudwatch_log_group" "virginia_health_log_group" {
#   name              = "/ec2/mysql-health/virginia"
#   retention_in_days = 7

#   depends_on = [
#     aws_instance.server_virginia_ec2
#   ]
# }

# # Virginia Health Log Stream
# resource "aws_cloudwatch_log_stream" "virginia_health_log_stream" {
#   log_group_name = aws_cloudwatch_log_group.virginia_health_log_group.name
#   name           = "virginia-health-log-stream"

#   depends_on = [
#     aws_cloudwatch_log_group.virginia_health_log_group,
#     aws_instance.server_virginia_ec2
#   ]
# }

# # Mumbai EC2 Instance with Docker and MySQL Health Check
# resource "aws_instance" "server_mumbai_ec2" {
#   provider                    = aws.mumbai
#   ami                         = "ami-08718895af4dfa033"
#   instance_type               = "t2.micro"
#   key_name                    = "key1"
#   subnet_id                   = aws_subnet.server_mumbai_public_subnet.id
#   security_groups             = [aws_security_group.server_mumbai_sg.id]
#   associate_public_ip_address = true

#   iam_instance_profile = "your_mumbai_iam_role"

#   user_data = <<-EOF
#     #!/bin/bash

#     # Switch to root user and install Docker
#     sudo yum install docker -y
#     sudo service docker start
#     sudo usermod -a -G docker ec2-user

#     # Docker login
#     echo "Dev@11411" | docker login -u "devesh11411" --password-stdin
#     docker pull mysql:latest

#     # Run a non-blocking MySQL health check
#     docker run --rm mysql mysql -h ${aws_db_instance.mumbai_rds_instance.endpoint} -u admin -p12290605 -e "SHOW DATABASES;" > /var/log/mysql-health.log 2>&1 &

#     # Install CloudWatch agent
#     sudo yum install -y amazon-cloudwatch-agent

#     # Create CloudWatch agent configuration file
#     sudo cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
#     {
#     "logs": {
#         "logs_collected": {
#         "files": {
#             "collect_list": [
#             {
#                 "file_path": "/var/log/mysql-health.log",
#                 "log_group_name": "/ec2/mysql-health/mumbai",
#                 "log_stream_name": "${aws_cloudwatch_log_stream.mumbai_health_log_stream.name}"
#             }
#             ]
#         }
#         }
#     }
#     }
#     EOT

#     # Apply correct permissions to the configuration file
#     sudo chmod 755 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

#     # Start CloudWatch agent
#     sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -m ec2

#   EOF

#   tags = {
#     Name = "Demo-Ec2-Mumbai"
#   }

#   depends_on = [
#     aws_db_instance.mumbai_rds_instance,
#     aws_ec2_transit_gateway_vpc_attachment.server_mumbai_attachment,
#     aws_security_group.server_mumbai_sg
#   ]
# }

# # Virginia EC2 Instance with Docker and MySQL Health Check
# resource "aws_instance" "server_virginia_ec2" {
#   provider                    = aws.virginia
#   ami                         = "ami-0ebfd941bbafe70c6"
#   instance_type               = "t2.micro"
#   key_name                    = "key2"
#   subnet_id                   = aws_subnet.server_virginia_public_subnet.id
#   security_groups             = [aws_security_group.server_virginia_sg.id]
#   associate_public_ip_address = true

#   iam_instance_profile = "your_virginia_iam_role"

#   user_data = <<-EOF
#     #!/bin/bash
#     sudo su -
#     sudo yum install docker -y
#     sudo service docker start
#     sudo usermod -a -G docker ec2-user
#     echo "Dev@11411" | docker login -u "devesh11411" --password-stdin
#     docker pull mysql:latest

#     # Non-blocking MySQL Health Check with Password Provided
#     docker run --rm mysql mysql -h ${aws_db_instance.virginia_rds_read_replica.endpoint} -u admin -p12290605 -e "SHOW DATABASES;" > /var/log/mysql-health.log 2>&1 &

#     # Install CloudWatch agent
#     yum install -y amazon-cloudwatch-agent
#     cat <<EOT >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
#     {
#       "logs": {
#         "logs_collected": {
#           "files": {
#             "collect_list": [
#               {
#                 "file_path": "/var/log/mysql-health.log",
#                 "log_group_name": "/ec2/mysql-health/mumbai",
#                 "log_stream_name": "${aws_cloudwatch_log_stream.virginia_health_log_stream.name}"
#               }
#             ]
#           }
#         }
#       }
#     }
#     EOT

#     # Start CloudWatch Agent
#     /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
#   EOF

#   tags = {
#     Name = "Demo-Ec2-Virginia"
#   }

#   depends_on = [
#     aws_db_instance.virginia_rds_read_replica,
#     aws_ec2_transit_gateway_vpc_attachment.server_virginia_attachment,
#     aws_security_group.server_virginia_sg
#   ]
# }
