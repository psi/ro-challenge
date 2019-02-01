#!/bin/bash

# Install and start Docker
sudo apt-get update -y
sudo apt-get install docker.io -y

sudo systemctl start docker
sudo systemctl enable docker

# Build the Hello app
cd /tmp/hello_app
sudo docker build -t hello:latest .

# Run the app
sudo docker run -d -p 80:4567 --restart=always hello:latest

