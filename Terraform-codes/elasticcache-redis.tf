resource "aws_elasticache_cluster" "litellm" {
  cluster_id         = "litellm-redis"
  engine             = "redis"
  node_type          = "cache.t2.micro"
  num_cache_nodes    = 1
  subnet_group_name  = aws_elasticache_subnet_group.default.name
  security_group_ids = [aws_security_group.redis.id]
  tags = {
    Name = "litellm-redis"
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "litellm-redis-subnet-group"
  subnet_ids = [data.aws_subnets.SubnetPrivateUSWEST2A.ids[0], data.aws_subnets.SubnetPrivateUSWEST2B.ids[0], data.aws_subnets.SubnetPrivateUSWEST2C.ids[0]]
  tags = {
    Name = "litellm-redis-subnet-group"
  }
}
