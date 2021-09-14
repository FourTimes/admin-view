resource "aws_s3_bucket" "b" {
  bucket = var.bucket
  acl    = "private"
  tags = merge({ Name = "${var.project}-${var.environment}-${var.bucket}" }, tomap(var.additional_tags))
}