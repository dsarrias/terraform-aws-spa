resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub OIDC CA thumbprint
}

resource "aws_iam_role" "github" {
  name = "GitHubS3Deployer"

  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

resource "aws_iam_role_policy" "github" {
  name   = "GitHubDeployerPolicy"
  role   = aws_iam_role.github.id
  policy = data.aws_iam_policy_document.github.json
}
