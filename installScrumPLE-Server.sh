#!/bin/bash

# ScrumPLE-Server installation script
# For CentOS 7

me="$(basename $0) ->"

# Update system
echo "$me Updating packages..."
yum update -y > /dev/null
echo "$me Done updating packages"

# Install Docker
echo "$me Installing Docker..."
echo -e "[dockerrepo]\n
name=Docker Repository\n
baseurl=https://yum.dockerproject.org/repo/main/centos/7/\n
enabled=1\n
gpgcheck=1\n
gpgkey=https://yum.dockerproject.org/gpg\n" > /etc/yum.repos.d/docker.repo	# Add official Docker repo
yum install -y docker-engine > /dev/null
echo "$me Done installing Docker"

# Configure Docker and containers
echo "$me Configuring Docker..."
systemctl enable docker.service > /dev/null
echo "$me Enabled Docker"
systemctl start docker > /dev/null
echo "$me Started Docker"

docker run scrumple-daemon
echo "$me Started ScrumPLE-Daemon container"
docker run scrumple-db
echo "$me Started ScrumPLE-DB container"
docker run scrumple-webserver
echo "$me Started ScrumPLE-WebServer container"

echo "$me Done configuring Docker"

# TODO Docker Compose
