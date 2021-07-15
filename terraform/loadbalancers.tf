module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.2"

  name = "waypoint-server-nlb-${var.region}"

  load_balancer_type = "network"

  vpc_id  = var.vpc-id
  subnets = var.subnet-ids
  # security_groups = var.security-groups-ids

  access_logs = {
    bucket = aws_s3_bucket.waypoint-loadbalancers-logs.id
  }

  target_groups = [
    {
      name_prefix          = "dft"
      backend_protocol     = "TLS"
      backend_port         = 9702
      target_type          = "instance"
      deregistration_delay = 60
      # health_check = {
      #   enabled             = true
      #   path                = "/"
      #   port                = "traffic-port"
      #   healthy_threshold   = 5
      #   unhealthy_threshold = 5
      # }
    },
    {
      name_prefix          = "wsrv-"
      backend_protocol     = "TCP"
      protocol_version     = "gRPC"
      backend_port         = 9701
      target_type          = "instance"
      deregistration_delay = 60
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



  depends_on = [
    aws_s3_bucket.waypoint-loadbalancers-logs
    # null_resource.build-waypoint-ami,
    # null_resource.build-waypoint-ami-runner
  ]
}

module "alb-runners" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.2"

  name = "waypoint-runner-alb-${var.region}"

  load_balancer_type = "application"

  vpc_id          = var.vpc-id
  subnets         = var.subnet-ids
  security_groups = local.create-sg == true ? [aws_security_group.alb-runner-sg[0].id] : var.security-groups-ids

  access_logs = {
    bucket = aws_s3_bucket.waypoint-loadbalancers-logs.id
  }

  target_groups = [
    {
      name_prefix          = "dft"
      backend_protocol     = "HTTP"
      backend_port         = var.app-backend-port
      target_type          = "instance"
      deregistration_delay = 60
      health_check = {
        enabled             = true
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 5
        interval            = 125
        timeout             = 120
        unhealthy_threshold = 5
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]



  depends_on = [
    aws_s3_bucket.waypoint-loadbalancers-logs
    # null_resource.build-waypoint-ami,
    # null_resource.build-waypoint-ami-runner
  ]
}