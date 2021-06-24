# Waypoint Deployment Example

<p align="center">
  <img src="/static/img/waypoint.png" alt="The Waypoint logo." width="400"/>
</p>

## Overview

This project is for you to use as a starting point for deploying Waypoint into your AWS environment. Fork the project, and start making changes to the configuration files to get HashiCorp Waypoint up and running for your downstream consumers.

**IMPORTANT**: THIS IS NOT AN OFFICIAL HASHICORP PROJECT.

## Tools/Products

The following products are utilized in this project.

* [HashiCorp Packer](https://www.packer.io/)
* [HashiCorp Terraform](https://www.terraform.io/)
* [HashiCorp Waypoint](https://www.waypointproject.io/)
* [AWS](https://aws.amazon.com/ec2/?ec2-whats-new.sort-by=item.additionalFields.postDateTime&ec2-whats-new.sort-order=desc)

## Getting Started
Fork the project to your own GitHub namespace, create a file named `terraform.tfvars` and start populating the file with values for the required Terraform input variables, see the [requirements section](#requirements) below to identify required inputs. As mentioned previously, feel free to to create more variables and customize the template as needed.

Next, create a file inside the folder `packer_config`, and name it `variables.auto.pkrvars.hcl`. Populate the variables with values values that corresponds to your compute environment. The content of the file should look similar to the example snippet below. Ensure you specify the AWS profile to use for the Packer build.

```tf
profile          = "myRole"
spot-instances   = ["t2.micro"]
role_arn         = "arn:aws:iam::00000000000000:role/myPackerRole"
instance-profile = "myAwesomeInstanceProfile"
description      = "An AMI sourced from Linux2 that hosts a Waypoint server"
public-ip        = true
tags = {
  environment = "test"
  packer      = "true"
}
```

Once you have created the two required files, `variables.auto.pkrvars.hcl`, and `terraform.tfvars`, you may begin to start creating the AMI. Follow the steps below to deploy the WayPoint server.

1. Navigate to the `packer_config` folder and issue the command `packer init && packer build .`. This will initialize Packer, download the required plugins and trigger the AMI build process. This may take up to 10 min depending on the EC2 instance size selected.
1. Once the AMI is created by Packer, navigate back to the root of the project, `cd ../`
1. Issue the command `terraform init && terraform plan`. This will initialize Terraform and provide a preview of the changes Terraform will make.
1. If everything looks good in the Terraform plan output then go ahead and issue the command `terraform apply -auto-approve`. Wait for all resources to come up. This may take about 5 min, depending on the instance sizes selected.
1. Go to the AWS SSM Parameter store and retrive the Waypoint token. The token is stored in the parameter named `waypoint-context`.
1. Navigate to your domain, and authenticate into the Waypoint UI.
1. Configure your local environment for Waypoint. See [Local Workstation Configuration](#local-workstation-configuration) for more guidance.
1. Configure the remote runner. See [Remote Runner](#remote-runner) for more guidance.
1. At this point, you may now start using Waypoint for application deployments 🚀🎉

## Packer


## Terraform

The Terraform code in this project may be used to deploy a Waypoint server to a hosting environment. The Terraform code takes advantage of existing Terraform modules in the Terraform Public Module Registry. The module for the [Autoscaling group](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest), and the [Network Load Balancer](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest) are from the Terraform module registry. The intention of the Terraform code is to get you started and for you to make changes as needed. This means adding more variables, adding additional resources, and so on. 


You can have Terraform trigger the Packer build job, if that is the desired behavior. Uncomment the following code snippet that is found inside of the `main.tf`

```hcl
resource "null_resource" "build-waypoint-ami" {

   triggers = {
     run = timestamp()
   }

   provisioner "local-exec" {
     command = "cd packer_config/ && packer build ."

     environment = {
       AWS_PROFILE = "automation"
     }
   }
}
```

Feel free to adjust the trigger as needed. There are commented `depends_on` added to all resources that depends on this step to be completed prior. 

### Terraform Usage

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.46.0 |

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
| [aws_ami.waypoint-ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
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

No outputs.



## Accessing Waypoint

### Local Workstation Configuration

In order to interact with the Waypoint server you must configure the Waypoint CLI with the proper context information. This information is provded by the Waypoint server in the UI. Click on the `CLI` button to get the proper information. 

 Note: The configuration provided by the Waypoint UI is missing the parameter flag `-server-tls-skip-verify=true`. Use the code snippet below and add your unique values to create a local Waypoint context.

```shell
waypoint context create \
    -server-addr=<yourDomainHere>:9701 \
    -server-auth-token=<YourTokenHere> \
    -server-require-auth=true \
    -server-tls-skip-verify=true \
    -set-default <yourDomainHere>
```

### Remote Runner
To setup a remote runner, you need to provide the following configuration to the remote instance. Make sure to add the actual token value provided by Waypoint in the command below.
```shell
WAYPOINT_SERVER_ADDR=<yourDomainHere>:9701 \
WAYPOINT_SERVER_TLS=true \
WAYPOINT_SERVER_TOKEN=<yourTokenHere> \
WAYPOINT_SERVER_TLS_SKIP_VERIFY=true \
waypoint runner agent
```