# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "centos64"
	config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box"
	config.vm.network :private_network, ip: "192.168.30.10"
	config.vm.provider "virtualbox" do |virtualbox|
		virtualbox.memory = 2048
		virtualbox.cpus = 2
	end

	config.vm.provision "shell", path: "provision/shell/system.sh"
	config.vm.provision "shell", path: "provision/shell/jdk.sh"
	config.vm.provision "shell", path: "provision/shell/zookeeper.sh"
	config.vm.provision "shell", path: "provision/shell/kafka.sh"
	config.vm.provision "shell", path: "provision/shell/mongod.sh"
	config.vm.provision "shell", path: "provision/shell/storm.sh"
	config.vm.provision "shell", path: "provision/shell/gungnir.sh"
end
