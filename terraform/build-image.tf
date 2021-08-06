################################################
# ONLY USE IF YOU WANT TERRAFORM TO BUILD
# THE PACKER IMAGES
# THIS REQUIRES UNCOMMENTING THE 
# DEPENDS_ON FOR THE RESPECTIVE NULL RESOURCES
#################################################



# resource "null_resource" "build-waypoint-ami" {

#   triggers = {
#     run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "cd ../packer/server/ && packer build ."

#     environment = {
#       AWS_PROFILE = var.profile
#     }
#   }
# }

# resource "null_resource" "build-waypoint-ami-runner" {

#   triggers = {
#     run = timestamp()
#   }

#   provisioner "local-exec" {
#     // Adding a sleep so that the data resource for identifying the latest AMI resolves the newly created AMI.
#     command = "cd ../packer/runner/ && packer build . && sleep 10"

#     environment = {
#       AWS_PROFILE = var.profile
#     }
#   }
# }