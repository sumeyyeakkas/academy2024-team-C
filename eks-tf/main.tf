data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "team-c-eks-role" {
  name               = "team-c-eks-cluster"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "team-c-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.team-c-eks-role.name
}

data "aws_vpc" "team-c-vpc" {
    id = "vpc-0e5c7fdc7b4bb1142"
}

data "aws_subnets" "private_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.team-c-vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

output "private_subnet_ids" {
  value = data.aws_subnets.private_subnet.ids
}

resource "aws_eks_cluster" "team-c-eks-cluster" {
  name     = "team-c-eks-cluster"
  role_arn = aws_iam_role.team-c-eks-role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.private_subnet.ids
  }


  depends_on = [
    aws_iam_role_policy_attachment.team-c-AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "team-c-eks-node-group-role" {
  name = "team-c-eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "team-c-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.team-c-eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "team-c-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.team-c-eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "team-c-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.team-c-eks-node-group-role.name
}

resource "aws_eks_node_group" "team-c-eks-node-group" {
  cluster_name    = aws_eks_cluster.team-c-eks-cluster.name
  node_group_name = "team-c-eks-node-group"
  node_role_arn   = aws_iam_role.team-c-eks-node-group-role.arn
  subnet_ids      = data.aws_subnets.private_subnet.ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  instance_types = ["t3.medium"]


  depends_on = [
    aws_iam_role_policy_attachment.team-c-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.team-c-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.team-c-AmazonEC2ContainerRegistryReadOnly,
  ]
}