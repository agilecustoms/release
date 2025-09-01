variable "aVersion" {}
variable "env" {}
variable "dist_bucket" {}

resource "aws_s3_bucket" "web" {
  bucket = "${var.env}.tt.agilecustoms.com"
}

data "aws_s3_objects" "src" {
  bucket = var.dist_bucket
  prefix = "tt-web/${var.aVersion}"
}

resource "aws_s3_object_copy" "files" {
  for_each = toset(data.aws_s3_objects.src.keys)
  source   = "${var.dist_bucket}/${each.key}"
  bucket   = aws_s3_bucket.web.id
  key      = each.key
}
