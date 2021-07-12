variable "region" {
  type        = string
  description = "The AWS region to target"
  default     = "us-east-1"
}

variable "description" {
  type = string
}

variable "spot-instances" {
  type        = list(string)
  description = "The EC2 SPOT instance types to use for the Packer build."
}

variable "instance-profile" {
  type        = string
  description = "The IAM instance profile (EC2) role to use"
}

variable "role_arn" {
  type        = string
  description = "The role arn for the aws profile"
}

variable "profile" {
  type        = string
  description = "The AWS profile to leverage for the build process"
}

variable "tags" {
  type        = map(string)
  description = "AWS tags to add to the AMI"
}

variable "public-ip" {
  type        = bool
  description = "To enable a public IP for the builder instance"
}

variable "vpc-id" {
  type = string
  description = "The VPC ID for Packer to to use for the AMI build"
}

variable "subnet-id" {
  type = string
  description = "The subnet ID for Packer to to use for the AMI build"
}

locals {
  image_suffix = formatdate("DD_MMM_YYYY", timestamp())
}