    resource "aws_eks_cluster" "saay_eks" {
    name = "saay_eks"
    role_arn = aws_iam_role.Saay_Eks_Role.arn
    
    vpc_config {
        subnet_ids = [ aws_subnet.private_subnet.id , aws_subnet.public_subnet.id ]
    }

    depends_on = [ aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy ]  //enable eks to access EC2 instances

    }

    resource "aws_iam_role" "Saay_Eks_Role" {
    name = "Saay_Eks_Role"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service" : "eks.amazonaws.com"
            }
        }]
    })
    }

    resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.Saay_Eks_Role.name
    }
