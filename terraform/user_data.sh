#!/bin/bash
set -e
sudo yum update -y
sudo amazon-linux-extras install git jq aws-cli docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
GITHUB_PAT=$(aws secretsmanager get-secret-value --secret-id github_pat --region "us-east-1" | jq -r .SecretString)
git clone -b codex/write-terraform-code-for-aws-setup https://spakai:$GITHUB_PAT@github.com/example/service_mesh_demo.git app
cd app
chmod +x /usr/local/bin/docker-compose
docker-compose up -d --build"


