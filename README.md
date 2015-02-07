Vagrant_CoreOS_Docker
=====================

## Install a container
1. Clone this repository
2. Make sure too have vagrant and virtualbox installed
3. Adapt the vagrantfile to install the containers you need
3. Run `vagrant up` from this repository
4. Wait till everything is done
5. Have fun using your development environment

## FAQ
### Reaching docker on the local computer
add `export DOCKER_HOST=tcp://172.17.8.2:2375` to your ~/.bashrc file on your mac / ubuntu this way you can use the docker commands in your terminal.

### Entering a container like you would with SSH
To enter a container, run: `./enter.sh <container>` OR `vagrant ssh -- sudo share/nsenter.sh <container>`

### The error default: Warning: Remote connection disconnect. Retrying... is being spammed
There are several possible solutions for this.

1. Clear the incorrect nfs records by opening the file `/etc/exports` and removing the line manually
2. Recreate your vagrant insecure key. You can do this by removing the` ~/.vagrant.d/insecure_prive_key` file on mac and ubuntu or `C:\Users\<username>\vagrant.d\insecure_private_key on windows`.

## Container configurations
### Ghost Blog (port 60001)
```javascript
{
    :docker_image_dir => "#{images_folder_location}",
    :docker_image_name => "ghost",
    :docker_container_name => "ghost_demo",
    :docker_run_command => "/usr/bin/docker run --name ghost_demo -t -d -i -p 60001:2368 -e environment=development ghost"
}
```

### MariaDB (password = root) (port 3306)

Note: This you can set the root password in the Dockerfile by changing: ENV MYSQL_ROOT_PASSWORD

```javascript
{
    :docker_image_dir => "#{images_folder_location}",
    :docker_image_name => "mariadb",
    :docker_container_name => "mariadb",
    :docker_run_command => "/usr/bin/docker run --name mariadb -t -d -i -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -v #{data_folder_location}/mariadb:/var/lib/mysql mariadb"
}
```

### Nginx (Loads the www folder to /var/www) (port 8080)
```javascript
{
    :docker_image_dir => "#{images_folder_location}",
    :docker_image_name => "nginx",
    :docker_container_name => "nginx",
    :docker_run_command => "/usr/bin/docker run --name nginx -t -d -i -p 80:80 -v #{data_folder_location}/nginx:/var/www -v #{logs_folder_location}/nginx:/var/log/nginx nginx",
    :docker_required_dir => "#{data_folder_location}/nginx"
}
```

### Node.JS (Development bash container with node.js installed, enter container by running ./enter.sh <containerName>) (port 8080)
```javascript
{
    :docker_image_dir => "#{images_folder_location}",
    :docker_image_name => "nodejs_bash",
    :docker_container_name => "node_app",
    :docker_run_command => "/usr/bin/docker run --name node_app -t -d -i -p 8080:8080 -v #{data_folder_location}/node_app:/var/www nodejs_bash",
    :docker_required_dir => "#{data_folder_location}/node_app"
}

> Note: append `--link mariadb:mariadb` before nodejs_bash to add the mariadb container to it.
```

### Node.JS (Will run the package.json located in the nodejs image automatically) (port 8080)
```javascript
{
    :docker_image_dir => "#{images_folder_location}",
    :docker_image_name => "nodejs",
    :docker_container_name => "node_demo",
    :docker_run_command => "/usr/bin/docker run --name node_demo -t -d -i -p 8080:8080 nodejs",
    :docker_required_dir => "#{images_folder_location}"
}
```

### MongoDB
```javascript
{
    :docker_image_dir => "#{images_folder_location}",
    :docker_image_name => "mongodb_server",
    :docker_container_name => "mongodb",
    :docker_run_command => "/usr/bin/docker run --name mongodb -t -d -i -p 27017:27017 mongodb_server",
    :docker_required_dir => "#{images_folder_location}"
}
```

## Reference
https://docs.docker.com/reference/commandline/cli/#exec
