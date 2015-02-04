Vagrant_CoreOS_Docker
=====================

## Install a container
1. Clone this repository
2. Make sure too have vagrant and virtualbox installed
3. Adapt the vagrantfile to install the containers you need
3. Run `vagrant up` from this repository
4. Wait till everything is done
5. Have fun using your development environment

## Tips
- add `export DOCKER_HOST=tcp://172.17.8.2:2375` to your ~/.bashrc file on your mac / ubuntu
this way you can use the docker commands in your terminal.
- To enter a container in SSH, run: `./enter.sh <container>` OR `vagrant ssh -- sudo share/nsenter.sh <container>`
- If you get the message  `default: Warning: Remote connection disconnect. Retrying...` being spammed, then you need to recreate your vagrant insecure key. You can do this by removing the ~/.vagrant.d/insecure_prive_key file on mac and ubuntu or C:\Users\<username>\vagrant.d\insecure_private_key on windows.

## Container configurations
### Ghost Blog (port 60001)
```javascript
{
    :docker_image_dir => "/home/core/share/docker",
    :docker_image_name => "ghost",
    :docker_container_name => "ghost_demo",
    :docker_run_command => "/usr/bin/docker run --name ghost_demo -t -d -i -p 60001:2368 -e environment=development ghost"
}
```

### MariaDB (password = root) (port 3306)

Note: This you can set the root password in the Dockerfile by changing: ENV MYSQL_ROOT_PASSWORD

```javascript
{
    :docker_image_dir => "/home/core/share/docker",
    :docker_image_name => "mariadb",
    :docker_container_name => "mariadb",
    :docker_run_command => "/usr/bin/docker run --name mariadb -t -d -i -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mariadb"
}
```

### Nginx (Loads the www folder to /var/www) (port 8080)
```javascript
{
    :docker_image_dir => "/home/core/share/docker",
    :docker_image_name => "nginx",
    :docker_container_name => "nginx",
    :docker_run_command => "/usr/bin/docker run --name nginx -t -d -i -p 80:80 -v /home/core/share/www:/var/www -v /home/core/share/logs:/var/log nginx",
    :docker_required_dir => "/home/core/share/www"
}
```

### Node.JS (Development bash container with node.js installed, enter container by running ./enter.sh <containerName>) (port 8080)
```javascript
{
    :docker_image_dir => "/home/core/share/docker",
    :docker_image_name => "nodejs_bash",
    :docker_container_name => "node_app",
    :docker_run_command => "/usr/bin/docker run --name node_app -t -d -i -p 8080:8080 nodejs_bash -v /home/core/share/www:/var/www",
    :docker_required_dir => "/home/core/share/www/node_app"
}
```

### Node.JS (Will run the package.json located in the nodejs image automatically) (port 8080)
```javascript
{
    :docker_image_dir => "/home/core/share/docker",
    :docker_image_name => "nodejs",
    :docker_container_name => "node_demo",
    :docker_run_command => "/usr/bin/docker run --name node_demo -t -d -i -p 8080:8080 nodejs",
    :docker_required_dir => "/home/core/share/docker"
}
```

### MongoDB
```javascript
{
    :docker_image_dir => "/home/core/share/docker",
    :docker_image_name => "mongodb_server",
    :docker_container_name => "mongodb",
    :docker_run_command => "/usr/bin/docker run --name mongodb -t -d -i -p 27017:27017 mongodb_server",
    :docker_required_dir => "/home/core/share/docker"
}
```

## Reference
https://docs.docker.com/reference/commandline/cli/#exec
