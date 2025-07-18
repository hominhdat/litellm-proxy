data "aws_vpc" "litellm_vpc" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-eks-litellm-proxy-cluster/VPC"]
  }
}

data "aws_subnets" "SubnetPrivateUSWEST2A" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-eks-litellm-proxy-cluster/SubnetPrivateUSWEST2A"]
  }
}
data "aws_subnets" "SubnetPrivateUSWEST2B" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-eks-litellm-proxy-cluster/SubnetPrivateUSWEST2B"]
  }
}
data "aws_subnets" "SubnetPrivateUSWEST2C" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-eks-litellm-proxy-cluster/SubnetPrivateUSWEST2C"]
  }
}

data "aws_subnets" "SubnetPublicUSWEST2A" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-eks-litellm-proxy-cluster/SubnetPublicUSWEST2A"]
  }
}

data "aws_subnets" "SubnetPublicUSWEST2B" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-eks-litellm-proxy-cluster/SubnetPublicUSWEST2B"]
  }
}

data "aws_subnets" "SubnetPublicUSWEST2C" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-eks-litellm-proxy-cluster/SubnetPublicUSWEST2C"]
  }
}


output "SubnetPrivateUSWEST2A" {
  value = data.aws_subnets.SubnetPrivateUSWEST2A.ids

}

output "SubnetPrivateUSWEST2B" {
  value = data.aws_subnets.SubnetPrivateUSWEST2B.ids

}

output "SubnetPrivateUSWEST2C" {
  value = data.aws_subnets.SubnetPrivateUSWEST2C.ids

}

output "SubnetPublicUSWEST2A" {
  value = data.aws_subnets.SubnetPublicUSWEST2A.ids

}

output "SubnetPublicUSWEST2B" {
  value = data.aws_subnets.SubnetPublicUSWEST2B.ids

}

output "SubnetPublicUSWEST2C" {
  value = data.aws_subnets.SubnetPublicUSWEST2C.ids

}