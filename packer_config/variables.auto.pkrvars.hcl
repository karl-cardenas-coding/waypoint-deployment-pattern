profile          = "automation"
spot-instances   = ["t2.micro"]
role_arn         = "arn:aws:iam::140040602879:role/automation-role"
instance-profile = "sb-vault-instance-profile"
description      = "An AMI sourced from Linux2 that hosts a Waypoint server"
public-ip        = true
tags = {
  environment = "test"
  packer      = "true"
}