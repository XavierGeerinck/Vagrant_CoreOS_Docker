#!/bin/bash
#============================================================
#          FILE:  install.sh
#         USAGE:  ./install.sh sitename
#   DESCRIPTION: This script will install the site with the given configuration
#
#       OPTIONS:  $1 The Imagename for the installed DockerContainer
#       OPTIONS:  $2 The name to call it after installation
#       OPTIONS:  $3 The Ports to be forwarded afterwards
#       OPTIONS:  $4 Environment variable
#       OPTIONS:  $5 Start Shell?
#       OPTIONS:  $6 Which dir do we require before starting?
#       OPTIONS:  $7 Shared Directory
#
#  REQUIREMENTS:  /
#        AUTHOR:  Xavier Geerinck (thebillkidy@gmail.com)
#       COMPANY:  /
#       VERSION:  1.3.0
#       CREATED:  18/08/13 20:12:38 CET
#      REVISION:  1.0 - Base structure
#                 1.1 - Added Port Forwarding
#                 1.2 - Finished Script for use on Feedient
#                 1.3 - Refactored script to make it cleaner
#                     - Changed parameters to:
#                         - docker_image_dir: Where is the docker image dir located?
#                         - docker_container_name: How will we name the container once installed?
#                         - image_to_install: What image will we install?
#                         - docker_run_command: What do we run when starting docker?
#                         - docker_required_dir: (optional) Do we have to wait on a dir that gets mounted?
#============================================================
# sudo sh install.sh test_api_server 8002:8002 staging false '/var/www/test.api.feedient.com' '/var/www:/var/www -v /var/log/feedient/api_server:/var/log'
# Config parameters
docker_binary=/usr/bin/docker

echo "Installing $2..."

echo "1: $1"
echo "2: $2"
echo "3: $3"
echo "4: $4"
echo "5: $5"

# Check parameters (We need the dockerpath too install + name for the image)
if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]; then
    echo "Usage: `basename $0` <docker_image_dir> <docker_image_name> <docker_container_name> <docker_run_command> <docker_required_dir>"
	echo "Example: "
	echo "Info: docker_image_dir: Where is the docker image dir located?"
	echo "Info: docker_container_name: How will we name the container once installed?"
	echo "Info: image_to_install: What image will we install?"
	echo "Info: docker_run_command: What do we run when starting docker?"
    echo "Info: docker_required_dir: (optional) Do we have to wait on a dir that gets mounted?"

	exit 0
fi

# Copy to better variable names
DOCKER_IMAGE_DIR=$1
DOCKER_IMAGE_NAME=$2
DOCKER_CONTAINER_NAME=$3
DOCKER_RUN_COMMAND=$4
DOCKER_REQUIRED_DIR=$5

# If docker is not installed then install it
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
cd $DOCKER_IMAGE_DIR/$DOCKER_IMAGE_NAME && \

echo "Building the docker image from the dockerfile located at: $DOCKER_IMAGE_DIR/$DOCKER_IMAGE_NAME" && \
echo "Build command: docker build -t \"$DOCKER_IMAGE_NAME\"" && \
docker build -t "$DOCKER_IMAGE_NAME" $DOCKER_IMAGE_DIR/$DOCKER_IMAGE_NAME

cmd="$DOCKER_RUN_COMMAND"

# Create the log directory if it doesn't exist
echo "Checking if $DOCKER_IMAGE_DIR/../logs/$DOCKER_CONTAINER_NAME exists"
if [ ! -d "$DOCKER_IMAGE_DIR/../logs/$DOCKER_CONTAINER_NAME" ]; then
    echo "Creating the $DOCKER_IMAGE_DIR/../logs/$DOCKER_CONTAINER_NAME directory"
    mkdir -p $DOCKER_IMAGE_DIR/../logs/$DOCKER_CONTAINER_NAME
fi

# Run docker cmd
echo "Running the command: $cmd"
echo "Starting up the docker container: $DOCKER_CONTAINER_NAME with command $cmd"
/bin/sh -c "$cmd"

# If required dir is set, then wait till it is mounted before starting the container
if [ ! -z $DOCKER_REQUIRED_DIR ]; then
    echo "Required dir, so create a while loop"

    cmd="while : ; do [[ -d \\\"$DOCKER_REQUIRED_DIR\\\" ]] && break; echo \\\"Waiting till \\\"$DOCKER_REQUIRED_DIR\\\" is mounted\\\"; sleep 1; done; $cmd;"
fi

# Check if dir exists
if [ ! -d "/etc/systemd/system/multi-user.target.wants" ]; then
    echo "Creating /etc/systemd/system/multi-user.target.wants directory"
    mkdir /etc/systemd/system/multi-user.target.wants
fi

# Create a systemd script that will start the container on boot, wait 10 secs so vagrant can sync dirs
echo "Installing the /etc/systemd/system/$DOCKER_CONTAINER_NAME.service script"

# Install the service (This removes the old container and then starts it)
# Remove docker containers of type: /bin/sh -c 'docker ps -a | grep "$1" | awk '\''{print \$1}'\'' | xargs docker rm;' && `echo $startCommand`
# Note: - is because it can fail, but we should still continue
# # /bin/sh -c ' while : ; do [[ -d " " ]] && break; echo "Waiting till directory is mounted"; sleep 1; done;
cat > /etc/systemd/system/multi-user.target.wants/$DOCKER_CONTAINER_NAME.1.service << EOF
[Unit]
Description=$DOCKER_CONTAINER_NAME
Requires=docker.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
Restart=always
RestartSec=1s
ExecStartPre=-/usr/bin/docker kill $DOCKER_CONTAINER_NAME
ExecStartPre=-/usr/bin/docker rm $DOCKER_CONTAINER_NAME
ExecStart=/bin/sh -c "$cmd"
ExecStopPre=/usr/bin/docker stop $DOCKER_CONTAINER_NAME
ExecStop=-/usr/bin/docker rm $DOCKER_CONTAINER_NAME

[Install]
WantedBy=multi-user.target

[X-Fleet]
X-Conflicts=$DOCKER_CONTAINER_NAME.*.service
EOF


# Reload the systemctl daemon
echo "Reloading systemctl daemon"
systemctl daemon-reload

echo "Done"
exit 0
