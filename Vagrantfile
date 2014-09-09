# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "user-data")
CONFIG = File.join(File.dirname(__FILE__), "config.rb")

$update_channel = "alpha"
nodes = [
    {
        :name => 'ghostdemo',
        :config => 'ghostdemo',
        :ip => '172.17.8.2',
        :box => "coreos-%s" % $update_channel,
        :url => "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel,
        :version => ">= 308.0.1",
        :ram => 1024,
        :cpus => 1,
        :gui => false
    }
]

# Defaults for config options defined in CONFIG
$update_channel = "alpha"
$enable_serial_logging = false

Vagrant.configure("2") do |config|
    nodes.each do |node|
        config.vm.define node[:name] do |node_config|
            nfs_setting = RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/

            # IF NO NFS: node_config.vm.synced_folder "www", "/var/www"
            #node_config.vm.synced_folder "www", "/var/www", :nfs => true, :mount_options => ['nolock,vers=3,udp']
            node_config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true,  :mount_options   => ['nolock,vers=3,udp']

            # Configure Machine details
            node_config.vm.box = node[:box]
            node_config.vm.box_url = node[:url]
            node_config.vm.box_version = node[:version]
            node_config.vm.hostname = node[:name]

            # Private network
            config.ssh.forward_agent = true
            node_config.vm.network :private_network, ip: node[:ip]

            # Forwards ports 60000 - 60010
            (60000..6010).each do |port|
                config.vm.network :forwarded_port, :host => port, :guest => port
            end

            # Copy over the machine discovery file when set
            if File.exist?(CLOUD_CONFIG_PATH)
              config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
              config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
            end

            config.vm.provider :virtualbox do |v|
                # On VirtualBox, we don't have guest additions or a functional vboxsf
                # in CoreOS, so tell Vagrant that so it can be smarter.
                v.check_guest_additions = false
                v.functional_vboxsf     = false
            end

            # plugin conflict
            if Vagrant.has_plugin?("vagrant-vbguest") then
                config.vbguest.auto_update = false
            end

            # Serial logging
            if $enable_serial_logging
              logdir = File.join(File.dirname(__FILE__), "log")
              FileUtils.mkdir_p(logdir)

              serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
              FileUtils.touch(serialFile)

              config.vm.provider :vmware_fusion do |v, override|
                v.vmx["serial0.present"] = "TRUE"
                v.vmx["serial0.fileType"] = "file"
                v.vmx["serial0.fileName"] = serialFile
                v.vmx["serial0.tryNoRxLoss"] = "FALSE"
              end

              config.vm.provider :virtualbox do |vb, override|
                vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
                vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
              end
            end

            # Forward docker tcp
            if $expose_docker_tcp
              config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
            end

            # Run our ghost container and mount it on port 4000 + sync folders.
            node_config.vm.provision :shell, :inline => "sh /home/core/share/install.sh docker/ghost_demo/ ghost_demo 60000:2368"
        end
    end
end
