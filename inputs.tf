variable "region" {
  type        = string
  description = "The AWS region to target"
}

variable "instance-type" {
  type        = string
  description = "The instance type to use for the Waypoint Deployment"
}

variable "instance-profile" {
  type        = string
  description = "The IAM Instance profile name to use on the EC2 instance"
}

variable "tags" {
  type        = map(any)
  description = "The default tags to provide the Terraform generated resources"
}

variable "vpc-id" {
  type        = string
  description = "The VPC ID to deploy Waypoint"
}

variable "subnet-ids" {
  type        = list(string)
  description = "A list of eligble subnets to deploy Waypoint resources"
}

variable "security-groups-ids" {
  type        = list(string)
  description = "A list of security groups to use for Waypoint resources"
}

variable "domain-name" {
  type        = string
  description = "The domain name for the certificate and ALB to advertise"
}