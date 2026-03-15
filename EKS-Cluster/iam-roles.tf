# External Secrets Operator
module "eso_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name_prefix}-eso"

  role_policy_arns = {
    secretsmanager = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
}

# Role for microservices to access S3
module "microservices_s3_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name_prefix}-microservices-s3"

  role_policy_arns = {
    s3 = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["default:s3-access-sa", "app-team:s3-access-sa"]
    }
  }
}

# Role for microservices to access DynamoDB
module "microservices_dynamodb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name_prefix}-microservices-dynamodb"

  role_policy_arns = {
    dynamodb = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["app-team:dynamodb-access-sa"]
    }
  }
}
