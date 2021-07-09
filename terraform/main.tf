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
    role_arn = var.role_arn
  }
}

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

  # depends_on = [
  #   null_resource.build-waypoint-ami
  # ]
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

  # depends_on = [
  #   null_resource.build-waypoint-ami
  # ]
}



# resource "null_resource" "build-waypoint-ami" {

#   triggers = {
#     run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "cd packer/server/ && packer build ."

#     environment = {
#       AWS_PROFILE = var.profile
#     }
#   }
# }

# resource "null_resource" "build-waypoint-ami-runner" {

#   triggers = {
#     run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "cd packer/runner/ && packer build ."

#     environment = {
#       AWS_PROFILE = var.profile
#     }
#   }
# }
# module "nlb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 6.2"

#   name = "waypoint-server-nlb-${var.region}"

#   load_balancer_type = "network"

#   vpc_id  = var.vpc-id
#   subnets = var.subnet-ids
#   # security_groups = var.security-groups-ids

#   # access_logs = {
#   #   bucket = "my-nlb-logs"
#   # }

#   target_groups = [
#     {
#       name_prefix          = "dft"
#       backend_protocol     = "TLS"
#       backend_port         = 9702
#       target_type          = "instance"
#       deregistration_delay = 60
#       # health_check = {
#       #   enabled             = true
#       #   path                = "/"
#       #   port                = "traffic-port"
#       #   healthy_threshold   = 5
#       #   unhealthy_threshold = 5
#       # }
#     },
#     {
#       name_prefix          = "wsrv-"
#       backend_protocol     = "TCP"
#       protocol_version     = "gRPC"
#       backend_port         = 9701
#       target_type          = "instance"
#       deregistration_delay = 60
#       #  health_check = {
#       #   enabled             = false
#       #   path                = "/"
#       #   interval            =  10
#       #   port                = 9701
#       #   healthy_threshold   = 5
#       #   unhealthy_threshold = 5
#       # }
#     }
#   ]

#   https_listeners = [
#     {
#       port               = 443
#       protocol           = "TLS"
#       certificate_arn    = aws_acm_certificate.domain.arn
#       target_group_index = 0
#     }
#   ]

#   http_tcp_listeners = [
#     {
#       port               = 9701
#       protocol           = "TCP"
#       target_group_index = 1
#     }
#   ]



#   # depends_on = [
#   #   null_resource.build-waypoint-ami
#   # ]
# }

# module "asg" {
#   source  = "terraform-aws-modules/autoscaling/aws"
#   version = "~> 4.0"

#   # Autoscaling group
#   name = "waypoint-deployment-${var.region}"

#   min_size                    = 1
#   max_size                    = 1
#   desired_capacity            = 1
#   wait_for_capacity_timeout   = "5m"
#   health_check_grace_period   = "30"
#   delete_timeout              = "5m"
#   health_check_type           = "EC2"
#   vpc_zone_identifier         = var.subnet-ids
#   iam_instance_profile_name   = var.instance-profile
#   associate_public_ip_address = true

#   target_group_arns = module.nlb.target_group_arns

#   termination_policies = ["OldestInstance"]

#   # Launch template
#   lt_name                = "waypoint-deployment-server-asg"
#   description            = "A launch template for deploying Waypoint"
#   update_default_version = true

#   use_lt     = true
#   create_lt  = true
#   lt_version = "$Latest"

#   image_id          = data.aws_ami.waypoint-ami.id
#   instance_type     = var.instance-type
#   ebs_optimized     = false
#   enable_monitoring = false

#   network_interfaces = [
#     {
#       delete_on_termination       = true
#       description                 = "eth0"
#       device_index                = 0
#       security_groups             = var.security-groups-ids
#       associate_public_ip_address = true
#     }
#   ]

#   block_device_mappings = [
#     {
#       # Root volume
#       device_name = "/dev/xvda"
#       no_device   = 0
#       ebs = {
#         delete_on_termination = true
#         encrypted             = true
#         volume_size           = 30
#         volume_type           = "gp2"
#       }
#     }
#   ]

#   metadata_options = {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 32
#   }

#   tags_as_map = var.tags

#   # depends_on = [
#   #   null_resource.build-waypoint-ami
#   # ]
# }

# module "asg-runners" {
#   source  = "terraform-aws-modules/autoscaling/aws"
#   version = "~> 4.0"

#   # Autoscaling group
#   name = "waypoint-runners-${var.region}"

#   min_size                    = 1
#   max_size                    = 1
#   desired_capacity            = 1
#   wait_for_capacity_timeout   = "5m"
#   health_check_grace_period   = "30"
#   delete_timeout              = "5m"
#   health_check_type           = "EC2"
#   vpc_zone_identifier         = var.subnet-ids
#   iam_instance_profile_name   = var.instance-profile
#   associate_public_ip_address = true

#   termination_policies = ["OldestInstance"]

#   # Launch template
#   lt_name                = "waypoint-deployment-runner-asg"
#   description            = "A launch template for deploying Waypoint"
#   update_default_version = true

#   use_lt     = true
#   create_lt  = true
#   lt_version = "$Latest"

#   image_id          = data.aws_ami.waypoint-ami-runner.id
#   instance_type     = var.instance-type
#   ebs_optimized     = false
#   enable_monitoring = false

#   network_interfaces = [
#     {
#       delete_on_termination       = true
#       description                 = "eth0"
#       device_index                = 0
#       security_groups             = var.security-groups-ids
#       associate_public_ip_address = true
#     }
#   ]

#   block_device_mappings = [
#     {
#       # Root volume
#       device_name = "/dev/xvda"
#       no_device   = 0
#       ebs = {
#         delete_on_termination = true
#         encrypted             = true
#         volume_size           = 30
#         volume_type           = "gp2"
#       }
#     }
#   ]

#   metadata_options = {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 32
#   }

#   tags_as_map = var.tags

  # instance_market_options = {
  #   market_type = "spot"
  #   spot_options = {
  #     spot_instance_type = var.instance-type
  #     block_duration_minutes = 60
  #   }
  # }

#   depends_on = [
#     module.asg,
#     module.nlb
#     # null_resource.build-waypoint-ami
#   ]
# }



resource "aws_ssm_parameter" "waypoint-context" {
  name  = "waypoint_context"
  type  = "SecureString"
  value = "default"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# The name of this parameter is expected by the backup_cron.sh script.
# DO NOT CHANGE UNLESS backup_cron.sh is modifed as well.
resource "aws_ssm_parameter" "waypoint-backup" {
  name  = "waypoint-backup-bucket"
  type  = "String"
  value = aws_s3_bucket.backup-storage.id
}

# This is used by the init-runner.sh script.
# It's how the runner becomes aware of the Waypoint server domain.
resource "aws_ssm_parameter" "waypoint-domain" {
  name  = "waypoint_domain"
  type  = "String"
  value = var.domain-name
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

resource "aws_acm_certificate" "domain" {
  domain_name       = var.domain-name
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "selected" {
  name         = var.domain-name
  private_zone = false
}

resource "aws_route53_record" "cert-validation" {
  for_each = {
    for dvo in aws_acm_certificate.domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# resource "aws_route53_record" "alias-record-for-custom-domain" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = var.domain-name
#   type    = "A"

#   alias {
#     name                   = module.nlb.lb_dns_name
#     zone_id                = module.nlb.lb_zone_id
#     evaluate_target_health = true
#   }
# }

resource "aws_s3_bucket" "backup-storage" {
  bucket        = var.backup-storage-bucket-name
  acl           = "private"
  force_destroy = var.force-destroy-back-bucket

  tags = {
    Name        = var.backup-storage-bucket-name
    Environment = "Dev"
  }
}
