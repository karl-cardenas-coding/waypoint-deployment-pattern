packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


data "amazon-ami" "latest-linux2" {
  filters = {
    virtualization-type = "hvm"
    name                = "amzn2-ami-hvm-*-x86_64-gp2"
    root-device-type    = "ebs"
  }
  owners      = ["137112412989"]
  most_recent = true
  region      = var.region

  assume_role {
    role_arn = var.role_arn
  }
}

source "amazon-ebs" "linux2" {
  ami_name                    = "waypoint_runner_linux2_${local.image_suffix}"
  instance_type               = "t2.micro"
  region                      = var.region
  ami_description             = var.description
  source_ami                  = data.amazon-ami.latest-linux2.id
  ssh_username                = "ec2-user"
  ssh_interface               = "session_manager"
  communicator                = "ssh"
  iam_instance_profile        = var.instance-profile
  associate_public_ip_address = var.public-ip
  force_deregister            = true
  force_delete_snapshot       = true
  tags                        = merge({ Name = "waypoint_runner_linux2_${local.image_suffix}" }, var.tags)
  snapshot_tags               = merge({ Name = "waypoint_runner_linux2_${local.image_suffix}" }, var.tags)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  vpc_id    = "vpc-6e92a815"
  subnet_id = "subnet-0fdfc630"

  #   vpc_filter {
  #     filters = {
  #       "isDefault" : true,
  #  #     "cidr" : "/16"
  #     }
  #   }
}

build {
  sources = ["source.amazon-ebs.linux2"]

  provisioner "file" {
    source      = "waypoint.service"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "init-runner.sh"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "echo Connected via SSM at '${build.User}@${build.Host}:${build.Port}'",
      "sudo mv /tmp/waypoint.service /usr/lib/systemd/system/",
      "chmod +x /tmp/init-runner.sh",
      "sudo mv /tmp/init-runner.sh /usr/bin/",
      "chmod +x /tmp/install.sh",
      "bash /tmp/install.sh"
    ]
  }
}