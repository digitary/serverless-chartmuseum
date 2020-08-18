resource "random_string" "random_name" {
  length  = 5
  special = false
  upper   = true
  lower   = false
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name   = "chartmuseum-${random_string.random_name.result}-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.s3_bucket}",
        "arn:aws:s3:::${var.s3_bucket}/*"
      ]

    },
    {
        "Effect": "Allow",
        "Action": "logs:CreateLogGroup",
        "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource":"arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chartmuseum.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.chartmuseum_api_gateway.id}/*/*/{proxy+}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "chartmuseum-${random_string.random_name.result}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_lambda_function" "chartmuseum" {
  filename      = "${path.module}/../../bin/main.zip"
  function_name = "chartmuseum-${random_string.random_name.result}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main"


  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${path.module}/../../bin/main.zip")

  runtime = "go1.x"

  environment {
    variables = {
      STORAGE               = "amazon"
      STORAGE_AMAZON_BUCKET = var.s3_bucket
      STORAGE_AMAZON_REGION = var.s3_bucket_region
      BASIC_AUTH_USER       = var.basic_auth_user
      BASIC_AUTH_PASS       = var.basic_auth_password
      LOG_LEVEL             = upper(var.log_level)
    }
  }
}