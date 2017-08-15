# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

#Quantity Tomcat VM
TVM = 2

Vagrant.configure('2') do |config|
  config.vm.box = 'bertvv/centos72'
  config.vm.provider 'virtualbox' do |vb|
    vb.gui = true
  end

  (1..TVM).each do |i|
    config.vm.define "tomcat#{i}" do |tomcat|
      tomcat.vm.network 'private_network', ip: "172.20.20.#{1 + i}"
      tomcat.vm.provision "shell", inline: "yum -y install tomcat tomcat-webapps tomcat-admin-webapps"
      tomcat.vm.provision "shell", inline: "systemctl enable tomcat"
      tomcat.vm.provision "shell", inline: "systemctl start tomcat"
      tomcat.vm.provision "shell", inline: "systemctl stop firewalld"
      tomcat.vm.provision "shell", inline: "mkdir -p /usr/share/tomcat/webapps/test/"
      tomcat.vm.provision "shell", inline: "echo 'tomcat#{i}' >> /usr/share/tomcat/webapps/test/index.html"
    end
  end

    config.vm.define "httpd" do |httpd|
      httpd.vm.hostname = "httpd"
      httpd.vm.network "private_network", ip: "172.20.20.10"
      httpd.vm.network "forwarded_port", guest: 80, host: 8080
      httpd.vm.provision "shell", inline: "yum -y install httpd"
      httpd.vm.provision "shell", inline: "systemctl enable httpd"
      httpd.vm.provision "shell", inline: "systemctl start httpd"
      httpd.vm.provision "shell", inline: "systemctl stop firewalld"
      httpd.vm.provision "shell", inline: "cp /vagrant/mod_jk.so /etc/httpd/modules/"
      httpd.vm.provision "shell", type: "shell", path: "./httpd.sh"
    end
  end



  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

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
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
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
