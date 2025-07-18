resource "aws_security_group" "default" {
  vpc_id      = data.aws_vpc.litellm_vpc.id
  name        = "litellm-security-group"
  description = "Security group for litellm"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "litellm-security-group"
  }
}
resource "aws_security_group" "jumphost" {
  vpc_id      = data.aws_vpc.litellm_vpc.id
  name        = "litellm-jumphost-security-group"
  description = "Security group for litellm jumphost"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "litellm-jumphost-security-group"
  }
}

resource "aws_security_group" "postgresql" {
  vpc_id      = data.aws_vpc.litellm_vpc.id
  name        = "litellm-postgresql-security-group"
  description = "Security group for litellm postgresql"
  # Allow access from the jumphost security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.jumphost.id]
  }
  # Allow access from the eks security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "litellm-postgresql-security-group"
  }
}

# security group for redis
resource "aws_security_group" "redis" {
  vpc_id      = data.aws_vpc.litellm_vpc.id
  name        = "litellm-redis-security-group"
  description = "Security group for litellm redis"
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "litellm-redis-security-group"
  }
}

#eks security group
resource "aws_security_group" "eks" {
  vpc_id      = data.aws_vpc.litellm_vpc.id
  name        = "litellm-eks-security-group"
  description = "Security group for litellm eks"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "litellm-eks-security-group"
  }
}