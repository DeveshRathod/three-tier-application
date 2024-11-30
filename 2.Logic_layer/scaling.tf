# Launch Template for Mumbai (based on AMI)
resource "aws_launch_template" "lt_private_mumbai" {
  provider      = aws.mumbai
  name          = "launch-template-private-mumbai"
  image_id      = aws_ami_from_instance.ami_mumbai.id
  instance_type = var.instance_type
  key_name      = var.key_mumbai

  # Specify the security group IDs here
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.alb_sg_mumbai.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "private-ec2-mumbai"
    }
  }

  depends_on = [aws_ami_from_instance.ami_mumbai]
}

# Launch Template for Virginia (based on AMI)
resource "aws_launch_template" "lt_private_virginia" {
  provider      = aws.virginia
  name          = "launch-template-private-virginia"
  image_id      = aws_ami_from_instance.ami_virginia.id
  instance_type = var.instance_type
  key_name      = var.key_virginia

  # Specify the security group IDs here
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.alb_sg_virginia.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "private-ec2-virginia"
    }
  }

  depends_on = [aws_ami_from_instance.ami_virginia]
}

# Auto Scaling Group for Mumbai
resource "aws_autoscaling_group" "asg_private_mumbai" {
  provider = aws.mumbai
  launch_template {
    id      = aws_launch_template.lt_private_mumbai.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.private_mumbai_2.id]
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  target_group_arns   = [aws_lb_target_group.tg_private_mumbai.arn]

  tag {
    key                 = "Name"
    value               = "private-ec2-asg-mumbai"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.lt_private_mumbai]
}

# Auto Scaling Group for Virginia
resource "aws_autoscaling_group" "asg_private_virginia" {
  provider = aws.virginia
  launch_template {
    id      = aws_launch_template.lt_private_virginia.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.private_virginia_2.id]
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  target_group_arns   = [aws_lb_target_group.tg_private_virginia.arn]

  tag {
    key                 = "Name"
    value               = "private-ec2-asg-virginia"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.lt_private_virginia]
}

# Scaling Policy based on CPU Utilization for Mumbai
resource "aws_autoscaling_policy" "cpu_policy_mumbai" {
  provider               = aws.mumbai
  name                   = "cpu-policy-mumbai"
  autoscaling_group_name = aws_autoscaling_group.asg_private_mumbai.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0 # Scale when CPU utilization exceeds 50%
  }

  depends_on = [aws_autoscaling_group.asg_private_mumbai]
}

# Scaling Policy based on CPU Utilization for Virginia
resource "aws_autoscaling_policy" "cpu_policy_virginia" {
  provider               = aws.virginia
  name                   = "cpu-policy-virginia"
  autoscaling_group_name = aws_autoscaling_group.asg_private_virginia.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0 # Scale when CPU utilization exceeds 50%
  }

  depends_on = [aws_autoscaling_group.asg_private_virginia]
}
