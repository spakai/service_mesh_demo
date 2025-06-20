#!/bin/bash

exec > >(tee /var/log/user_data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e
sudo yum update -y
sudo yum install amazon-linux-extras  git jq aws-cli docker -y
sudo service docker start
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose && sudo chmod +x /usr/bin/docker-compose && docker-compose --version

export GITHUB_PAT=$(aws secretsmanager get-secret-value --secret-id github_pat20 --region "us-east-1" | jq -r .SecretString)
sudo git clone -b codex/write-terraform-code-for-aws-setup https://spakai:$GITHUB_PAT@github.com/spakai/service_mesh_demo.git app
cd app
sudo docker-compose up -d --build


