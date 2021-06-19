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



module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.1"

  name = "waypoint-alb-${var.region}"

  load_balancer_type = "network"

  vpc_id  = var.vpc-id
  subnets = var.subnet-ids
  # security_groups = var.security-groups-ids

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  target_groups = [
    {
      name_prefix      = "dft"
      backend_protocol = "TLS"
      backend_port     = 9702
      target_type      = "instance"
      # health_check = {
      #   enabled             = true
      #   path                = "/"
      #   port                = "traffic-port"
      #   healthy_threshold   = 5
      #   unhealthy_threshold = 5
      # }
    },
    {
      name_prefix      = "dft"
      backend_protocol = "TCP"
      protocol_version = "gRPC"
      backend_port     = 9701
      target_type      = "instance"
      #  health_check = {
      #   enabled             = false
      #   path                = "/"
      #   interval            =  10
      #   port                = 9701
      #   healthy_threshold   = 5
      #   unhealthy_threshold = 5
      # }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = aws_acm_certificate.domain.arn
      target_group_index = 0
    }
  ]

   http_tcp_listeners = [
    {
      port               = 9701
      protocol           = "TCP"
      target_group_index = 1
    }
  ]

  # depends_on = [
  #   null_resource.build-waypoint-ami
  # ]
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "waypoint-deployment-${var.region}"

  min_size                    = 1
  max_size                    = 1
  desired_capacity            = 1
  wait_for_capacity_timeout   = "1m"
  health_check_grace_period   = "60"
  health_check_type           = "EC2"
  vpc_zone_identifier         = var.subnet-ids
  iam_instance_profile_name   = var.instance-profile
  associate_public_ip_address = false

  target_group_arns = module.alb.target_group_arns

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

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain-name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
