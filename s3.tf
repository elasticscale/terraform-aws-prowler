data "aws_kms_key" "s3key" {
  key_id = "alias/aws/s3"
}


module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  // randomid
  bucket                   = "${var.prefix}-scanresults"
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = data.aws_kms_key.s3key.id
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
}