#!/bin/bash
# Install Docker
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io awscli

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Retrieve the worker token from S3
aws s3 cp s3://my-swarm-tokens-bucket/worker-token /tmp/worker-token

# Join the Docker Swarm
sudo sh /tmp/worker-token

