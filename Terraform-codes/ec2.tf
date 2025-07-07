# data source get latest Amazon Linux 2 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
}

# ec2 key pair for SSH access jumphost instance
resource "aws_key_pair" "jumphost" {
  key_name   = "jumphost-ssh-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "litellm-jumphost-keypair"
  }
}

# put key pair in the AWS parameters store
resource "aws_ssm_parameter" "jumphost_keypair" {
  name        = "/litellm/jumphost/keypair"
  type        = "String"
  value       = file("~/.ssh/id_rsa")
  tags = {
    Name = "litellm-jumphost-keypair"
  }
}

resource "aws_instance" "jumphost" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jumphost.id]
  key_name      = aws_key_pair.jumphost.key_name
  tags = {
    Name = "litellm-jumphost"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

# public ip for the jumphost instance
resource "aws_eip" "jumphost" {
  instance = aws_instance.jumphost.id
  tags = {
    Name = "litellm-jumphost-eip"
  }
  lifecycle {
    create_before_destroy = true
  }
}
# associate the EIP to the jumphost instance
resource "aws_eip_association" "jumphost" {
  instance_id   = aws_instance.jumphost.id
  allocation_id = aws_eip.jumphost.id
  lifecycle {
    create_before_destroy = true
  }
}

# Output the public IP of the jumphost instance
output "jumphost_public_ip" {
  value = aws_eip.jumphost.public_ip
}

