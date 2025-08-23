resource "aws_lambda_function" "app" {

  package_type     = "Zip"
  runtime          = "python3.13"
  s3_bucket        = var.dist_bucket
  s3_key           = "${local.app_name}/${var.aVersion}/app.zip"
  handler          = "envapi.lambda_function.lambda_handler"
}
