#!/bin/bash
#============================================================
#          FILE:  install.sh
#         USAGE:  ./install.sh sitename
#   DESCRIPTION: This script will install the site with the given configuration
#
#       OPTIONS:  $1 The path to the Dockerfile (Using this project as root)
#       OPTIONS:  $2 The Imagename for the installed DockerContainer
#       OPTIONS:  $3 The Ports to be forwarded afterwards
#  REQUIREMENTS:  /
#        AUTHOR:  Xavier Geerinck (thebillkidy@gmail.com)
#       COMPANY:  Feedient
#       VERSION:  1.1.0
#       CREATED:  18/08/13 20:12:38 CET
#      REVISION:  ---
#============================================================
# Config parameters
docker_binary=/usr/bin/docker

# Check parameters (We need the dockerpath too install + name for the image)
if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo "Usage: `basename $0` <DockerfilePath> <ImageName> <PortForwards>"
	echo "Example: `basename $0` docker/ghost_demo/ ghost_demo"
	echo "Info: The DockerfilePath is the path from this as root to the directory where the Dockerfile is located"

	exit 0
fi

# If chef is not installed then install it
echo "Checking if Docker is installed..."
if ! test -f "$docker_binary"; then
	echo "Downloading and installing docker"

    # Update binaries
	sudo apt-get update

	# Install wget & ca-certificates
	sudo apt-get install -y wget ca-certificates docker.io

	# Link and fix paths
	ln -sf /usr/bin/docker.io /usr/local/bin/docker
    sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io

    # Start Docker on server boot
    update-rc.d docker.io defaults
else
	echo "Docker is already installed"
fi

echo "Running docker"
cd /home/core/share/$1 && \
echo "Building the docker image from the dockerfile located at: /home/core/share/"$1 && \
docker build -t "$2" . && \
echo "Starting up the docker container: $2" && \
docker run -d -p $3 "ghost_demo"

echo "Done"
exit 0
