terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::140040602879:role/automation-role"
  }
}

data "aws_ami" "waypoint-ami" {
  most_recent = true
  name_regex  = "waypoint_linux2_*"
  owners      = ["self"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = [false]
  }

  # depends_on = [
  #   null_resource.build-waypoint-ami
  # ]
}

# resource "null_resource" "build-waypoint-ami" {

#   triggers = {
#     run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "cd packer_config/ && packer build ."

#     environment = {
#       AWS_PROFILE = "automation"
#     }
#   }
# }



# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 6.0"

#   name = "waypoint-alb-${var.region}"

#   load_balancer_type = "application"

#   vpc_id          = var.vpc-id
#   subnets         = var.subnet-ids
#   security_groups = var.security-groups-ids

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  # target_groups = [
  #   {
  #     name_prefix      = "dft"
  #     backend_protocol = "HTTPS"
  #     backend_port     = 9702
  #     target_type      = "instance"
  #   }
  # ]

  # https_listeners = [
  #   {
  #     port                 = 443
  #     certificate_arn      = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
  #   }
  # ]

  # depends_on = [
  #   null_resource.build-waypoint-ami
  # ]
# }

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "waypoint-deployment-${var.region}"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = "5m"
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.subnet-ids

  # load_balancers = module.alb.target_group_arns

  termination_policies = ["OldestInstance"]

  # Launch template
  lt_name                = "waypoint-deployment-asg"
  description            = "A launch template for deploying Waypoint"
  update_default_version = true

  use_lt    = true
  create_lt = true

  image_id          = data.aws_ami.waypoint-ami.id
  instance_type     = var.instance-type
  ebs_optimized     = false
  enable_monitoring = false

  # block_device_mappings = [
  #   {
  #     # Root volume
  #     device_name = "/dev/xvda"
  #     no_device   = 0
  #     ebs = {
  #       delete_on_termination = true
  #       encrypted             = true
  #       volume_size           = 20
  #       volume_type           = "gp2"
  #     }
  #   }
  # ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  tags_as_map = var.tags

  # depends_on = [
  #   null_resource.build-waypoint-ami
  # ]
}

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = "wpt"

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
  }
}