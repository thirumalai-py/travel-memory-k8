# Setup Docker on the EC2

Steps to deploy the Docker image on the EC2 along with the NGINX

## Install Docker
sudo apt update
sudo apt install -y docker.io docker-compose

## Add Permission to the user from ubuntu user
- Add User to the docker user group
sudo usermod -aG docker $USER

- Create a new Group
newgrp docker

## Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws --version
aws configure

## Authenticate ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 975050024946.dkr.ecr.ap-south-1.amazonaws.com


## Install NGINX
sudo apt install nginx
