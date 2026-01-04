# 1. Create the OIDC Provider (The "Door")
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  
  # AWS uses a standard thumbprint for GitHub. 
  # It is safe to hardcode this well-known thumbprint.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Create the Role (The "Key")
resource "aws_iam_role" "github_actions" {
  name = "github-actions-deployer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            # 🔒 SECURITY CRITICAL: This ensures ONLY your repo can use this role
            # Format: repo:<org-name>/<repo-name>:*
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 3. Create custom least-privilege policy
resource "aws_iam_policy" "terraform_deploy" {
  name        = "terraform-deploy-policy"
  description = "Least privilege policy for Terraform deployments via GitHub Actions"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # VPC permissions
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcAttribute",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeSubnets",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeAvailabilityZones",          
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      },
      # S3 state backend permissions
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          "arn:aws:s3:::tw-terraform-state*",
          "arn:aws:s3:::tw-terraform-state*/*"
        ]
      }
    ]
  })
}

# 4. Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "terraform_deploy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_deploy.arn
}

# 5. Output the Role ARN (You will need this for GitHub Secrets)
output "github_role_arn" {
  value = aws_iam_role.github_actions.arn
}