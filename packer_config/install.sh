#!/bin/sh
echo "Starting install script...."
## Setup Waypoint user
sudo useradd --system -md /home/waypoint --shell /bin/false waypoint
sudo mkdir --parents /opt/waypoint
sudo touch /opt/waypoint/data.db
sudo chown --recursive waypoint:waypoint /opt/waypoint
sudo chown --recursive waypoint:waypoint /etc/waypoint.d
## Setup Waypoint as a startup process
sudo systemctl enable waypoint
## Install Waypoint, SSM Agent, AWS CLI v2, jq, Docker and other updates
sudo yum update -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install waypoint jq
/usr/bin/waypoint version
sudo yum install -y https://s3.region.amazonaws.com/amazon-ssm-region/latest/linux_amd64/amazon-ssm-agent.rpm
sudo yum install -y docker
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
## Enable startup process
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl status amazon-ssm-agent
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker waypoint
# Download the script
curl -sSLo install.sh https://install.hclq.sh
sh install.sh
hclq --version
# if sudo systemctl start waypoint;
# then
#     sudo systemctl status waypoint
# else
#     sudo journalctl -u waypoint
# fi