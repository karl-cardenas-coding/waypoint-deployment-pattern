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
#     command = "cd packer/server/ && packer build ."

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
#     command = "cd packer/runner/ && packer build ."

#     environment = {
#       AWS_PROFILE = var.profile
#     }
#   }
# }