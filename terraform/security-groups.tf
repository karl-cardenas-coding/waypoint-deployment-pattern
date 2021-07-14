resource "aws_security_group" "server" {
  count = local.create-sg == true ? 1 :0

  name        = "waypoint-server-sg"
  description = "Allow HTTPS & gRPC inbound traffic to the Waypoint server"
  vpc_id      = var.vpc-id


ingress {
    description      = "VPC Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.selected.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.selected.ipv6_cidr_block]
  }

  ingress {
    description      = "TLS from outside"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    ingress {
    description      = "gRPC from outside"
    from_port        = 9701
    to_port          = 9701
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "runners" {
  count = local.create-sg == true ? 1 :0
  
  name        = "waypoint-runner-sg"
  description = "Allow traffic to the Waypoint runners"
  vpc_id      = var.vpc-id

  ingress {
    description      = "VPC Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.selected.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.selected.ipv6_cidr_block]
  }

  ingress {
    description      = "App traffic from the outside"
    from_port        = var.app-backend-port
    to_port          = var.app-backend-port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}