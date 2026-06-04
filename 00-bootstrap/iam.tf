resource "aws_iam_user" "admin" {
  # checkov:skip=CKV_AWS_273: estudo — conta pessoal de laboratório usa IAM user em vez de SSO/Identity Center
  name = "AdminUser"
  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "admin" {
  # checkov:skip=CKV_AWS_274: estudo — usuário admin pessoal do laboratório
  # checkov:skip=CKV_AWS_40: estudo — policy anexada direto ao usuário admin pessoal (sem grupo)
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = local.tags
}

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ronaldobrisa/aws-certification-portfolio:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "GitHubActionsRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  # checkov:skip=CKV_AWS_274: estudo — role de deploy do CI usa admin amplo; TODO escopar permissões mínimas por módulo
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "terraform_local_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.admin.arn]
    }
  }
}

resource "aws_iam_role" "terraform_local" {
  name               = "TerraformLocalRole"
  assume_role_policy = data.aws_iam_policy_document.terraform_local_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "terraform_local" {
  # checkov:skip=CKV_AWS_274: estudo — role de deploy local usa admin amplo; TODO escopar permissões mínimas
  role       = aws_iam_role.terraform_local.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
