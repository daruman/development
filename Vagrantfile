# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "centos70"
    config.vm.box_url = "https://f0fff3908f081cb6461b407be80daf97f07ac418.googledrive.com/host/0BwtuV7VyVTSkUG1PM3pCeDJ4dVE/centos7.box"
    config.vm.hostname = "develop.local"

    config.vm.network :private_network, ip: "192.168.30.10"
    config.ssh.forward_agent = true

    config.vm.provider :virtualbox do |v|
        # virtualboxのGUI上の名前変更
        v.name = "develop.local"

        # 割り当てメモリ変更
        v.customize ["modifyvm", :id, "--memory", 1024]
    end

    config.vm.provision :ansible do |ansible|
        ansible.limit = 'all'
        ansible.playbook = 'ansible/site.yml'
        ansible.inventory_path = "ansible/local"
        ansible.host_key_checking = false

        # debug用
        # ansible.verbose =  'vvvv'
    end
end
