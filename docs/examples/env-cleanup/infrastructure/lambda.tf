resource "aws_lambda_function" "app" {
  package_type = "Image"
  image_uri    = "${var.aws_account_dist}.dkr.ecr.${var.region}.amazonaws.com/${local.app_name}:${var.aVersion}"
}
