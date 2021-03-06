## This data resource is configured to retrieve the AMI created by the Packer job.
data "aws_ami" "waypoint-ami" {
  most_recent = true
  name_regex  = "waypoint_server_linux2_*"
  owners      = ["self"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = [false]
  }

  depends_on = [
    # null_resource.build-waypoint-ami,
    # null_resource.build-waypoint-ami-runner
  ]
}

## This data resource is configured to retrieve the AMI created by the Packer job.
data "aws_ami" "waypoint-ami-runner" {
  most_recent = true
  name_regex  = "waypoint_runner_linux2_*"
  owners      = ["self"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = [false]
  }

  depends_on = [
    # null_resource.build-waypoint-ami,
    # null_resource.build-waypoint-ami-runner
  ]
}

data "aws_elb_service_account" "main" {}

data "aws_vpc" "selected" {
  id = var.vpc-id
}