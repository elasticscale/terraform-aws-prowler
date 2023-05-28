resource "aws_datasync_location_s3" "locations3" {
  depends_on    = [module.bucket, aws_iam_role.datasync]
  s3_bucket_arn = module.bucket.s3_bucket_arn
  subdirectory  = "/"
  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync.arn
  }
}

module "datasync_sg" {
  source                                = "terraform-aws-modules/security-group/aws"
  name                                  = "${var.prefix}-datasync"
  vpc_id                                = module.vpc.vpc_id
  ingress_with_source_security_group_id = []
  egress_rules                          = ["all-all"]
}

resource "aws_datasync_location_efs" "locationefs" {
  efs_file_system_arn = aws_efs_file_system.efs.arn
  ec2_config {
    security_group_arns = [module.datasync_sg.security_group_arn]
    subnet_arn          = module.vpc.private_subnet_arns[0]
  }
}

resource "aws_datasync_task" "example" {
  destination_location_arn = aws_datasync_location_s3.locations3.arn
  name                     = "test"
  source_location_arn      = aws_datasync_location_efs.locationefs.arn
}