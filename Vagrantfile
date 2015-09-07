# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "hansode/centos-6.7-x86_64"
	config.vm.hostname = "internal-vagrant"
	config.vm.network :private_network, type: "dhcp"
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
	config.vm.provision "shell", path: "provision/shell/sample.sh"
end
