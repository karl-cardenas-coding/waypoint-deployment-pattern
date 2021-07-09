## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_iam_service_linked_role.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_route53_record.cert-validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.backup-storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_ssm_parameter.waypoint-backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.waypoint-context](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.waypoint-domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ami.waypoint-ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.waypoint-ami-runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup-storage-bucket-name"></a> [backup-storage-bucket-name](#input\_backup-storage-bucket-name) | The name of the S3 bucket to store server snapshots | `string` | n/a | yes |
| <a name="input_domain-name"></a> [domain-name](#input\_domain-name) | The domain name for the certificate and ALB to advertise | `string` | n/a | yes |
| <a name="input_force-destroy-back-bucket"></a> [force-destroy-back-bucket](#input\_force-destroy-back-bucket) | A setting to allow Terraform to force destroy a S3 bucket and its content | `bool` | `false` | no |
| <a name="input_instance-profile"></a> [instance-profile](#input\_instance-profile) | The IAM Instance profile name to use on the EC2 instance | `string` | n/a | yes |
| <a name="input_instance-type"></a> [instance-type](#input\_instance-type) | The instance type to use for the Waypoint Deployment | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | The AWS Profile to use for Packer builds and Terraform runs | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to target | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | The role arn for the AWS role to assume when executing Terraform | `string` | n/a | yes |
| <a name="input_security-groups-ids"></a> [security-groups-ids](#input\_security-groups-ids) | A list of security groups to use for Waypoint resources | `list(string)` | n/a | yes |
| <a name="input_subnet-ids"></a> [subnet-ids](#input\_subnet-ids) | A list of eligble subnets to deploy Waypoint resources | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The default tags to provide the Terraform generated resources | `map(any)` | n/a | yes |
| <a name="input_vpc-id"></a> [vpc-id](#input\_vpc-id) | The VPC ID to deploy Waypoint | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_waypoint-domain-url"></a> [waypoint-domain-url](#output\_waypoint-domain-url) | n/a |
