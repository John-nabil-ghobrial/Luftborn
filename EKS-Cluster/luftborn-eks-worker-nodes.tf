#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "luftborn-nodes" {
  name = "luftborn-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "luftborn-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.luftborn-nodes.name
}

resource "aws_iam_role_policy_attachment" "luftborn-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.luftborn-nodes.name
}

resource "aws_iam_role_policy_attachment" "luftborn-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.luftborn-nodes.name
}

resource "aws_eks_node_group" "luftborn-Cluster" {
  cluster_name    = aws_eks_cluster.luftborn-Cluster.name
  node_group_name = "luftborn-Cluster"
  node_role_arn   = aws_iam_role.luftborn-nodes.arn
  subnet_ids      = aws_subnet.luftborn-Cluster[*].id
  instance_types = [ "t2.large" ]
  
  remote_access {
    ec2_ssh_key               = var.EC2-SSh-Key
    
  }

  tags = {
    
    Name        = "VA-Dev-Workers"
  }

  scaling_config {
    desired_size = 5
    max_size     = 7
    min_size     = 5
  }

  depends_on = [
    aws_iam_role_policy_attachment.luftborn-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.luftborn-nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.luftborn-nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}