# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2" # 変更しない

# 下記はhostOSのhostsの設定と合わせる
IP_ADDRESS = "192.168.30.10"
HOST_NAME  = "develop.local"

# apacheのドキュメントルートになる
DOC_ROOT = "/vagrant/projectCode/webroot"

# 使用するansible tags
# TAGS = Array['CentOs6', 'apache22', 'php56', 'mysql56', 'project']
# TAGS = Array['CentOs7', 'apache24', 'php56', 'mysql56', 'SELinux']
TAGS = Array['CentOs7', 'SELinux']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "centos70"
    config.vm.box_url = "https://f0fff3908f081cb6461b407be80daf97f07ac418.googledrive.com/host/0BwtuV7VyVTSkUG1PM3pCeDJ4dVE/centos7.box"

    # config.vm.box = "hnakamur/centos6.5-x64"
    # config.vm.hostname = "jfn.local"

    # 建てるサーバが1つでも、以下のdefineがないと自動生成されるvagrant_ansible_inventoryに
    # 出力されるサーバ設定用変数名が`default`になってしまう

    # webserver
    config.vm.define "webserver" do |webserver|
        webserver.vm.hostname = HOST_NAME
        webserver.vm.network :private_network, ip: IP_ADDRESS
        webserver.ssh.forward_agent = true

        webserver.vm.provider :virtualbox do |v|
            # virtualboxのGUI上の名前変更
            v.name = HOST_NAME

            # 割り当てメモリ変更
            v.customize ["modifyvm", :id, "--memory", 1024]
        end
    end

    # provision
    config.vm.provision "ansible" do |ansible|
        # vagrantが自動生成するものを使用するのでインベントリファイルは指定しない

        ansible.groups = { "webservers" => ["webserver"] }
        ansible.playbook = 'ansible/site.yml'

        # hostOSの~/.ssh/known_hostsに書き込まない
        ansible.host_key_checking = false

        ansible.tags = TAGS.join(',')
        ansible.extra_vars = {
            'servername' => HOST_NAME,
            'ip_address' => IP_ADDRESS,
            'doc_root'   => DOC_ROOT
        }

        # debug用
        # ansible.verbose =  'vvvv'
    end
end
