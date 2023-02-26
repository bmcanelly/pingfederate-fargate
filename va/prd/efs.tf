
resource aws_efs_file_system this {
  creation_token = local.name
  encrypted      = true

  performance_mode = "generalPurpose"

  tags = {
    Name        = local.name
    Description = "Managed by Terraform"
  }
}

resource aws_efs_mount_target this {
  for_each = toset(data.aws_subnets.private.ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [module.efs_sg.security_group_id]
}

resource aws_efs_access_point this_in {
  file_system_id = aws_efs_file_system.this.id

  root_directory {
    path = "/in"
  }

  posix_user {
    uid = 9031
    gid = 9999
    secondary_gids = [0]
  }

  tags = {
    Name        = "in"
    Description = "Managed by Terraform"
  }
}

resource aws_efs_access_point data {
  file_system_id = aws_efs_file_system.this.id

  root_directory {
    path = "/data"
  }

  posix_user {
    uid = 9031
    gid = 9999
    secondary_gids = [0]
  }

  tags = {
    Name        = "data"
    Description = "Managed by Terraform"
  }
}
