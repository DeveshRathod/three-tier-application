# Bastion Host EC2 Instance in Mumbai
resource "aws_instance" "bastion_mumbai" {
  provider                    = aws.mumbai
  ami                         = var.ami_mumbai
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_mumbai_1.id
  associate_public_ip_address = true
  key_name                    = var.key_mumbai

  security_groups = [aws_security_group.bastion_sg_mumbai.id]

  tags = {
    Name = "bastion-host-mumbai"
  }
}

# Private EC2 Instance in Mumbai
resource "aws_instance" "private_ec2_mumbai" {
  provider      = aws.mumbai
  ami           = var.ami_mumbai
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_mumbai_1.id
  key_name      = var.key_mumbai

  security_groups = [aws_security_group.private_ec2_sg_mumbai.id]

  # User data for setting up the backend app
  user_data = file("${path.module}/backend-mumbai.sh")

  tags = {
    Name = "private-ec2-mumbai"
  }
}

# Bastion Host EC2 Instance in Virginia
resource "aws_instance" "bastion_virginia" {
  provider                    = aws.virginia
  ami                         = var.ami_virginia
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_virginia_1.id
  associate_public_ip_address = true
  key_name                    = var.key_virginia

  security_groups = [aws_security_group.bastion_sg_virginia.id]

  tags = {
    Name = "bastion-host-virginia"
  }
}

# Private EC2 Instance in Virginia
resource "aws_instance" "private_ec2_virginia" {
  provider      = aws.virginia
  ami           = var.ami_virginia
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_virginia_1.id
  key_name      = var.key_virginia

  security_groups = [aws_security_group.private_ec2_sg_virginia.id]

  user_data = file("${path.module}/backend-virginia.sh")


  tags = {
    Name = "private-ec2-virginia"
  }
}

# Wait for Application to be Ready in Mumbai
resource "null_resource" "wait_for_application_mumbai" {
  depends_on = [aws_instance.private_ec2_mumbai]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file("./key1.pem")
      host                = aws_instance.private_ec2_mumbai.private_ip
      bastion_host        = aws_instance.bastion_mumbai.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file("./key1.pem")
    }

    inline = [
      # Retry every 10 seconds, timeout after 20 minutes
      "timeout 1200 bash -c 'while ! sudo systemctl is-active --quiet backend-app.service; do echo Waiting for backend-app.service; sleep 10; done'"
    ]
  }
}

# Similar configuration for Virginia instance
resource "null_resource" "wait_for_application_virginia" {
  depends_on = [aws_instance.private_ec2_virginia]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file("./key2.pem")
      host                = aws_instance.private_ec2_virginia.private_ip
      bastion_host        = aws_instance.bastion_virginia.public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file("./key2.pem")
    }

    inline = [
      "timeout 1200 bash -c 'while ! sudo systemctl is-active --quiet backend-app.service; do echo Waiting for backend-app.service; sleep 10; done'"
    ]
  }
}


# AMI creation for Mumbai EC2
resource "aws_ami_from_instance" "ami_mumbai" {
  name                    = "ami-mumbai"
  provider                = aws.mumbai
  snapshot_without_reboot = true
  source_instance_id      = aws_instance.private_ec2_mumbai.id

  depends_on = [null_resource.wait_for_application_mumbai, null_resource.wait_for_application_virginia]
}

# AMI creation for Virginia EC2
resource "aws_ami_from_instance" "ami_virginia" {
  name                    = "ami-virginia"
  provider                = aws.virginia
  snapshot_without_reboot = true
  source_instance_id      = aws_instance.private_ec2_virginia.id

  depends_on = [null_resource.wait_for_application_mumbai, null_resource.wait_for_application_virginia]
}
