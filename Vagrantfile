# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
config.vm.box = "bertvv/centos72"
config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  # vb.memory = "1024"
end

config.vm.define "server1" do |server1|
    server1.vm.hostname = "server1"
    server1.vm.provision "yum", type: "shell",
      inline: "sudo yum install git -y"
    server1.vm.provision "shell", inline: "git clone https://github.com/bandzzz/training.git"
    server1.vm.provision "shell", inline: "cat training/hello.txt"
    server1.vm.provision "shell", inline: "echo '172.20.20.11  server2' >> /etc/hosts"
    server1.vm.network "private_network", ip: "172.20.20.10"
end
config.vm.define "server2" do |server2|
    server2.vm.hostname = "server2"
    server2.vm.provision "shell", inline: "echo '172.20.20.10  server1' >> /etc/hosts"
    server2.vm.network "private_network", ip: "172.20.20.11"
end
config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port


  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #
  #   # Customize the amount of memory on the VM:

  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
