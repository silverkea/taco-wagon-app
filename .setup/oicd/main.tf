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

# 3. Attach AWS managed PowerUserAccess policy
# Provides permissions for application development tasks and can create and 
# configure resources and services that support AWS aware application development
resource "aws_iam_role_policy_attachment" "power_user" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# 4. Output the Role ARN (You will need this for GitHub Secrets)
output "github_role_arn" {
  value = aws_iam_role.github_actions.arn
}