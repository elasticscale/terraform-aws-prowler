module "efs_sg" {
  depends_on = [module.task_sg]
  source     = "terraform-aws-modules/security-group/aws"
  name       = "${var.prefix}-efs"
  vpc_id     = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "nfs-tcp"
      source_security_group_id = module.task_sg.security_group_id
    },
    {
      rule                     = "nfs-tcp"
      source_security_group_id = module.datasync_sg.security_group_id
    },    
  ]
  // todo lockdown?
  egress_rules = ["all-all"]
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${var.prefix}-scanresults"
  // todo policy for efs?
  // todo
  #   encrypted = true
}

resource "aws_efs_mount_target" "mount_target" {
  for_each        = toset(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [module.efs_sg.security_group_id]
}

resource "aws_efs_access_point" "accesspoint" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
  }
}