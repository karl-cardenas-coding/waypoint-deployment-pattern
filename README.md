# Waypoint Deployment Pattern

<p align="center">
  <img src="/static/img/waypoint.png" alt="The Waypoint logo." width="400"/>
</p>

## Overview

This project is for you to use as a starting point for deploying Waypoint into your AWS environment. Fork the project, and start making changes to the configuration files to get HashiCorp Waypoint up and running for your downstream consumers.

**IMPORTANT**: THIS IS NOT AN OFFICIAL HASHICORP PROJECT.

## Architecture

<p align="center">
  <img src="/static/img/Waypoint Architecture.png" alt="The Waypoint logo." width="800"/>
</p>

## Tools/Products

The following products are utilized in this project.

* [HashiCorp Packer](https://www.packer.io/)
* [HashiCorp Terraform](https://www.terraform.io/)
* [HashiCorp Waypoint](https://www.waypointproject.io/)
* [AWS Account](https://aws.amazon.com/ec2/?ec2-whats-new.sort-by=item.additionalFields.postDateTime&ec2-whats-new.sort-order=desc)
* [AWS SSM Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

## Requirements

* An AWS account
* AWS credentials and permissions to deploy AWS resources. Please see the [Terraform README](./terraform/README.md) for a list of all AWS resources deployed.
* A custom domain and hosted zone is needed. Without a valid TLS certificate AWS load balancers are unable to handle gRPC traffic.
* An AWS VPC


## Getting Started

Fork the project to your own GitHub namespace. 

### Create the Waypoint AMIs

The AMIs are created through HashiCorp Packer. The AMIs are based of the latest version of the Amazon Linux2 AMI. 

Next, create a file inside the folder `packer/server` directory and name it `variables.auto.pkrvars.hcl`. Populate the variables with values values that corresponds to your compute environment. The content of the file should look similar to the example snippet below. Ensure you specify the AWS profile to use for the Packer build.

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


Once you have created the two required files, `variables.auto.pkrvars.hcl`, and `terraform.tfvars`, you may begin to create the AMI. Go ahead and issue the command `packer init && packer build .` to start the AMI build process.  This will initialize Packer and download the required plugins, as well as trigger the AMI build process. This may take up to 10 min depending on the EC2 instance size selected.

Do the same steps for the `packer/runner` directory.

Once the AMIs are created by Packer, navigate back to the root of the project, `cd ../../`

### Deploy Waypoint

Follow the steps below to deploy the WayPoint server.

Go the the terraform directory. Create a file named `terraform.tfvars` in the terraform folder and start populating the file with values for the required Terraform input variables, see the [requirements section](./terraform/README.md) below to identify required inputs. As mentioned previously, feel free to to create more variables and customize the template as needed.

The Terraform code in this project may be used to deploy a Waypoint server to a hosting environment. The Terraform code takes advantage of existing Terraform modules in the Terraform Public Module Registry. The module for the [Autoscaling group](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest), and the [Network Load Balancer](https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest) are from the Terraform module registry. The intention of the Terraform code is to get you started and for you to make changes as needed. This means adding more variables, adding additional resources, and so on. 

1. Create a file named `terraform.tfvars`, and populate the values for all the required variables.
1. Issue the command `terraform init`. This will initialize Terraform.
1. Issue the command `terraform plan`. This will generate a preview of the infrastructure that will be created.
1. If everything looks good in the Terraform plan output then go ahead and issue the command `terraform apply -auto-approve`. Wait for all resources to come up. This may take about 5 min, depending on the instance sizes selected.
1. Go to the AWS SSM Parameter store and retrive the Waypoint token. The token is stored in the parameter named `waypoint-context`.
1. Navigate to your domain, and authenticate into the Waypoint UI.
1. Configure your local environment for Waypoint. See [Local Workstation Configuration](#local-workstation-configuration) for more guidance.
1. At this point, you may now start using Waypoint for application deployments 🚀🎉


You can have Terraform trigger the Packer build job, if that is the desired behavior. Uncomment the following code snippet that is found inside of the `main.tf`. There are two `null_resources` available, one for each AMI (server and runner).

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

Feel free to adjust the trigger as needed. 
There are commented `depends_on` added to all resources that depends on this step to be completed prior.
Please review the Terraform [README.MD](./terraform/README.md) for more details. 

## Accessing Waypoint

The Terraform output will provide the URL for the Waypoint server and the application loadbalancer. In order to access the Waypoint UI you need the Waypoint context token. This token can be found in the AWS SSM Parameter store. In the AWS Paramater store, retrive the context token from the secret named `waypoint-context`. Next, go to the custom domain endpoint you provided the Terraform configuration, example `https://abc.deployment.com`. 

This will take you to the Waypoint UI authentication page. Provide the token so tha you may log into the Waypoint server. After you have authenticated into Waypoint, you may now configure your workstation to interact with Waypoint.

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
