profile          = "automation"
spot-instances   = ["t2.micro"]
role_arn         = "arn:aws:iam::140040602879:role/automation-role"
instance-profile = "sb-vault-instance-profile"
description      = "An AMI sourced from Linux2 that hosts a Waypoint server"
public-ip        = true
vpc-id           = "vpc-6e92a815"
subnet-id        = "subnet-0fdfc630"
tags = {
  environment = "test"
  packer      = "true"
}