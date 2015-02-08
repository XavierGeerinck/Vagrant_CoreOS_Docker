# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

VAGRANTFILE_API_VERSION = "2"

# shared_dir: <Destination>:<Location>
forwardPorts = [ 27017, 80, 8000, 8080, 3306, 2375 ]
synched_folder_location = "/home/core/share"
data_folder_location = "#{synched_folder_location}/data"
logs_folder_location = "#{synched_folder_location}/logs"
images_folder_location = "#{synched_folder_location}/docker"

# Install these, parameters: <docker_image_dir> <docker_image_name> <docker_container_name> <docker_run_command> <docker_required_dir>
# docker_image_dir: Where is the docker image dir located?
# docker_container_name: How will we name the container once installed?
# image_to_install: What image will we install?
# docker_run_command: What do we run when starting docker?
# docker_required_dir: (optional) Do we have to wait on a dir that gets mounted?
dockerContainers = [
    # Create a container with MariaDB installed with root as the password
    {
        :docker_image_dir => "#{images_folder_location}",
        :docker_image_name => "mariadb",
        :docker_container_name => "mariadb",
        :docker_run_command => "/usr/bin/docker run --name mariadb -t -d -i -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -v #{data_folder_location}/mariadb:/var/lib/mysql mariadb"
    },

    # Create a docker container with node.js installed and bash running
    {
        :docker_image_dir => "#{images_folder_location}",
        :docker_image_name => "nodejs_bash",
        :docker_container_name => "node_app",
        :docker_run_command => "/usr/bin/docker run --name node_app -t -d -i -p 8080:8080 -v #{data_folder_location}/node_app:/var/www --link mariadb:mariadb nodejs_bash",
        :docker_required_dir => "#{data_folder_location}/node_app"
    },
    # Nginx
    {
        :docker_image_dir => "#{images_folder_location}",
        :docker_image_name => "nginx",
        :docker_container_name => "nginx",
        :docker_run_command => "/usr/bin/docker run --name nginx -t -d -i -p 80:80 -v #{data_folder_location}/nginx:/var/www -v #{logs_folder_location}/nginx:/var/log/nginx nginx",
        :docker_required_dir => "#{data_folder_location}/nginx"
    }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # IF NO NFS: node_config.vm.synced_folder "www", "/var/www"
    #config.vm.synced_folder "www", "/var/www", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    config.vm.synced_folder ".", "#{synched_folder_location}", id: "core", :nfs => true,  :mount_options   => ['noatime,nosuid,nolock,vers=3,udp'], :map_uid => 0, :map_gid => 0

    # Configure Machine details
    config.vm.box = "coreos-alpha"
    config.vm.box_url = "http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"
    config.vm.box_version = ">= 575.0.0"
    config.vm.hostname = "DevelopmentServer"

    # Private network
    config.vm.network :private_network, ip: "172.17.8.2"

    # Fix authentication because of CoreOS
    config.ssh.insert_key = false

    # Forward Ports
    forwardPorts.each do |port|
        config.vm.network :forwarded_port, :host => port, :guest => port
    end

    # Disable guest additions
    config.vm.provider :virtualbox do |v|
        # On VirtualBox, we don't have guest additions or a functional vboxsf
        # in CoreOS, so tell Vagrant that so it can be smarter.
        v.check_guest_additions = false
        v.functional_vboxsf     = false

        # Set box details
        v.memory = 1024
        v.cpus = 1
        v.gui = false
    end

    # plugin conflict
    if Vagrant.has_plugin?("vagrant-vbguest") then
        config.vbguest.auto_update = false
    end

    # Forward docker tcp port, should be: tcp://IP:2375
    # Run 'export DOCKER_HOST=tcp://IP:2375' to use it
    if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: 2375, auto_correct: true
    end

    # Script for removing all the containers
    $scriptRemoveAllContainers = <<-'EOF'
    if [ `docker ps --no-trunc -aq | wc -l` -gt 0 ]
        then
        echo "Removing all the containers before provisioning"
        docker stop `docker ps --no-trunc -aq`
        docker rm `docker ps --no-trunc -aq`
    fi
    EOF

    $scriptRemoveServiceFiles = <<-'EOF'
        echo "Removing all service files before provisioning them"
        if [ -d "/etc/systemd/system/multi-user.target.wants" ]
        then
            rm -r /etc/systemd/system/multi-user.target.wants
        fi
    EOF

    # Enable the docker API and reload docker
    config.vm.provision :shell, :inline => "cat > /etc/systemd/system/docker-tcp.socket << 'EOF'
    [Unit]
    Description=Docker Socket for the API

    [Socket]
    ListenStream=2375
    Service=docker.service
    BindIPv6Only=both

    [Install]
    WantedBy=sockets.target"

    config.vm.provision :shell, :inline => "
    echo 'Ignore the warning, we need to stop and restart to enable proxy';
    systemctl enable docker-tcp.socket;
    systemctl stop docker;
    systemctl start docker-tcp.socket;
    systemctl start docker"

    # Remove all containers before provisioning them
    config.vm.provision :shell, :inline => $scriptRemoveAllContainers

    # Remove all service files before provisioning them
    config.vm.provision :shell, :inline => $scriptRemoveServiceFiles

    # Run the containers from the config above
    dockerContainers.each do |container|
        config.vm.provision :shell, :inline => "sh /home/core/share/install.sh '#{container[:docker_image_dir]}' '#{container[:docker_image_name]}' '#{container[:docker_container_name]}' '#{container[:docker_run_command]}' '#{container[:docker_required_dir]}'"
    end
end
