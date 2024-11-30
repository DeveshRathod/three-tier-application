# Target Group for Private EC2 in Mumbai
resource "aws_lb_target_group" "tg_private_mumbai" {
  provider = aws.mumbai
  name     = "tg-private-mumbai"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 30
    interval            = 60
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
  }


}

# Target Group for Private EC2 in Virginia
resource "aws_lb_target_group" "tg_private_virginia" {
  provider = aws.virginia
  name     = "tg-private-virginia"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.virginia.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 30
    interval            = 60
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
  }


}

# Register Mumbai EC2 with Target Group
resource "aws_lb_target_group_attachment" "tg_attachment_mumbai" {
  provider         = aws.mumbai
  target_group_arn = aws_lb_target_group.tg_private_mumbai.arn
  target_id        = aws_instance.private_ec2_mumbai.id
  port             = 4000
}

# Register Virginia EC2 with Target Group
resource "aws_lb_target_group_attachment" "tg_attachment_virginia" {
  provider         = aws.virginia
  target_group_arn = aws_lb_target_group.tg_private_virginia.arn
  target_id        = aws_instance.private_ec2_virginia.id
  port             = 4000
}


# Application Load Balancer for EC2 Instances in Mumbai
resource "aws_lb" "alb_mumbai" {
  provider           = aws.mumbai
  name               = "alb-mumbai"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_mumbai_1.id, aws_subnet.public_mumbai_2.id]
  security_groups    = [aws_security_group.alb_sg_mumbai.id]

  enable_deletion_protection = false

  tags = {
    Name = "alb-mumbai"
  }
}

# Application Load Balancer for EC2 Instances in Virginia
resource "aws_lb" "alb_virginia" {
  provider           = aws.virginia
  name               = "alb-virginia"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_virginia_1.id, aws_subnet.public_virginia_2.id]
  security_groups    = [aws_security_group.alb_sg_virginia.id]


  enable_deletion_protection = false

  tags = {
    Name = "alb-virginia"
  }
}

# Listener for Application Load Balancer in Mumbai
resource "aws_lb_listener" "listener_mumbai" {
  provider          = aws.mumbai
  load_balancer_arn = aws_lb.alb_mumbai.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_private_mumbai.arn
  }
}

# Listener for Application Load Balancer in Virginia
resource "aws_lb_listener" "listener_virginia" {
  provider          = aws.virginia
  load_balancer_arn = aws_lb.alb_virginia.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_private_virginia.arn
  }
}
