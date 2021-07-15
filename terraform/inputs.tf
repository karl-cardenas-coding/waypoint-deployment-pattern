variable "region" {
  type        = string
  description = "The AWS region to target"
}

variable "environment" {
  type        = string
  description = "The environment this terraform is deploying to"
}

variable "profile" {
  type        = string
  description = "The AWS Profile to use for Packer builds and Terraform runs"
}

variable "role_arn" {
  type        = string
  description = "The role arn for the AWS role to assume when executing Terraform"
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
  default     = []
}

variable "domain-name" {
  type        = string
  description = "The domain name for the certificate and ALB to advertise"
}

variable "backup-storage-bucket-name" {
  type        = string
  description = "The name of the S3 bucket to store server snapshots"
}

variable "waypoint-loadbalancers-log-bucket" {
  type        = string
  description = "The name of the bucket to for all Waypoint loadbalancers to send logs to"
}

variable "force-destroy-back-bucket" {
  type        = bool
  description = "A setting to allow Terraform to force destroy a S3 bucket and its content"
  default     = false
}

variable "app-backend-port" {
  type        = number
  description = "The backend port for the application that the Waypoint runner alb needs to forward requests to"
  default     = 49153
}

locals {
  create-sg = var.security-groups-ids != [] ? true : false
}