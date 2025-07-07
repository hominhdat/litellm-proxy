resource "aws_eks_cluster" "litellm" {
  name     = "litellm-eks-cluster"
  version = "1.33"
  role_arn = aws_iam_role.eks.arn
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = aws_subnet.private[*].id
    public_access_cidrs = ["0.0.0.0/0"]
    security_group_ids = [aws_security_group.eks.id]
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  depends_on = [aws_iam_role_policy_attachment.eks]
  tags = {
    Name = "litellm-eks-cluster"
  }
}
resource "aws_iam_role" "eks" {
  name = "litellm-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = "litellm-eks-role"
  }
}
resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_vpc" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_vpc_resources" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}
resource "aws_iam_role_policy_attachment" "eks_logs" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLogsPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_metrics" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSMetricsPolicy"
}
# eks service role custom policy
resource "aws_iam_policy" "eks_service_role" {
  name        = "litellm-eks-service-role-policy"
  description = "Custom policy for EKS service role"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ]
      Resource = "*"
    }, {
      Effect = "Allow"
      Action = [
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "ec2:DescribeRouteTables",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ]
      Resource = "*"
    }, {
      Effect = "Allow"
      Action = [
        "iam:PassRole"
      ]
      Resource = aws_iam_role.eks.arn
    },
    {
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    },
    {
      Effect = "Allow"
      Action = [
        "cloudwatch:PutMetricData"
      ]
      Resource = "*"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "eks_service_role" {
  role       = aws_iam_role.eks.name
  policy_arn = aws_iam_policy.eks_service_role.arn
}
resource "aws_eks_node_group" "litellm" {
  cluster_name    = aws_eks_cluster.litellm.name
  node_group_name = "litellm-eks-node-group"
  node_role_arn   = aws_iam_role.eks_worker.arn
  subnet_ids      = aws_subnet.private[*].id
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.small"]
  disk_size      = 30
  tags = {
    Name = "litellm-eks-node-group"
  }
}
resource "aws_iam_role" "eks_worker" {
  name = "litellm-eks-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["ec2.amazonaws.com", "eks.amazonaws.com"]
      }
    }]
  })
}

# IAM policies for EKS worker nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_cni" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSCNI"
}
resource "aws_iam_role_policy_attachment" "eks_worker_registry_power_user" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_role_policy_attachment" "eks_worker_registry_pull_only" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}
resource "aws_iam_role_policy_attachment" "eks_worker_ssm_managed_instance" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "eks_worker_cloudwatch_agent" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_autoscaler" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = aws_iam_policy.eks_worker_autoscaler.arn
}
resource "aws_iam_policy" "eks_worker_autoscaler" {
  name        = "litellm-eks-worker-autoscaler-policy"
  description = "Custom policy for EKS worker node autoscaler"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
            "Action"= [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions"
            ]
            "Resource"= "*"
            "Effect"= "Allow"
        },
        {
            "Action"= [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeImages",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ]
            "Resource"= "*"
            "Effect"= "Allow"
        }]
  })
  
}
resource "aws_iam_role_policy_attachment" "eks_worker_ebs" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = aws_iam_policy.eks_worker_ebs.arn
}
resource "aws_iam_policy" "eks_worker_ebs" {
  name        = "litellm-eks-worker-ebs-policy"
  description = "Custom policy for EKS worker node EBS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DescribeVolumes",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:DescribeSnapshots"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_alb" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSALBIngressControllerPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_appmesh" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSAppMeshPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_s3" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSS3Policy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_kms" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSKMSPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_secrets" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSSecretsManagerPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_cloudwatch" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSCloudWatchPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_logs" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLogsPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_worker_metrics" {
  role       = aws_iam_role.eks_worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSMetricsPolicy"
}

## EKS Add-ons
resource "aws_eks_addon" "litellm_coredns" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "coredns"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_kube_proxy" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_vpc_cni" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_appmesh" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "appmesh"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_alb_ingress" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "alb-ingress-controller"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_ebs_csi" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "ebs-csi-driver"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_s3_csi" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "s3-csi-driver"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_kms" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "kms"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_secrets_manager" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "secrets-manager"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_cloudwatch" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "cloudwatch"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_logs" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "logs"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_metrics" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "metrics"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_registry" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "registry"
  resolve_conflicts = "OVERWRITE"
}
resource "aws_eks_addon" "litellm_autoscaler" {
  cluster_name = aws_eks_cluster.litellm.name
  addon_name   = "cluster-autoscaler"
  resolve_conflicts = "OVERWRITE"
}

# OpenID Connect Provider for EKS
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url = aws_eks_cluster.litellm.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  tags = {
    Name = "litellm-eks-oidc-provider"
  }
} 

# Output the EKS cluster name and endpoint
output "eks_cluster_name" {
  value = aws_eks_cluster.litellm.name
}
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.litellm.endpoint
}
# Output the EKS node group name
output "eks_node_group_name" {
  value = aws_eks_node_group.litellm.node_group_name
}
# Output the EKS worker role ARN
output "eks_worker_role_arn" {
  value = aws_iam_role.eks_worker.arn
}
# Output the EKS cluster OIDC provider URL
output "eks_oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks_oidc.url
}
