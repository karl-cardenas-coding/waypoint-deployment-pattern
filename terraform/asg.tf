module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "waypoint-deployment-${var.region}"

  min_size                    = 1
  max_size                    = 1
  desired_capacity            = 1
  wait_for_capacity_timeout   = "5m"
  health_check_grace_period   = "30"
  delete_timeout              = "5m"
  health_check_type           = "EC2"
  vpc_zone_identifier         = var.subnet-ids
  iam_instance_profile_name   = var.instance-profile
  associate_public_ip_address = true

  target_group_arns = module.nlb.target_group_arns

  termination_policies = ["OldestInstance"]

  # Launch template
  lt_name                = "waypoint-deployment-server-asg"
  description            = "A launch template for deploying Waypoint"
  update_default_version = true

  use_lt     = true
  create_lt  = true
  lt_version = "$Latest"

  image_id          = data.aws_ami.waypoint-ami.id
  instance_type     = var.instance-type
  ebs_optimized     = false
  enable_monitoring = false

  network_interfaces = [
    {
      delete_on_termination       = true
      description                 = "eth0"
      device_index                = 0
      security_groups             = local.create-sg == true ? [aws_security_group.server[0].id] : var.security-groups-ids
      associate_public_ip_address = true
    }
  ]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  tags_as_map = var.tags

  # depends_on = [
  # null_resource.build-waypoint-ami,
  # null_resource.build-waypoint-ami-runner
  # ]
}

module "asg-runners" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name              = "waypoint-runners-${var.region}"
  target_group_arns = module.alb-runners.target_group_arns

  min_size                    = 1
  max_size                    = 1
  desired_capacity            = 1
  wait_for_capacity_timeout   = "5m"
  health_check_grace_period   = "30"
  delete_timeout              = "5m"
  health_check_type           = "EC2"
  vpc_zone_identifier         = var.subnet-ids
  iam_instance_profile_name   = var.instance-profile
  associate_public_ip_address = true

  termination_policies = ["OldestInstance"]

  # Launch template
  lt_name                = "waypoint-deployment-runner-asg"
  description            = "A launch template for deploying Waypoint"
  update_default_version = true

  use_lt     = true
  create_lt  = true
  lt_version = "$Latest"

  image_id          = data.aws_ami.waypoint-ami-runner.id
  instance_type     = var.instance-type
  ebs_optimized     = false
  enable_monitoring = false

  network_interfaces = [
    {
      delete_on_termination       = true
      description                 = "eth0"
      device_index                = 0
      security_groups             = local.create-sg == true ? [aws_security_group.runners[0].id] : var.security-groups-ids
      associate_public_ip_address = true
    }
  ]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  tags_as_map = var.tags

  depends_on = [
    module.asg,
    module.nlb
    # null_resource.build-waypoint-ami,
    # null_resource.build-waypoint-ami-runner
  ]
}
