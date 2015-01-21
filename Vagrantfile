# -*- mode: ruby -*-
# vi: set ft=ruby :

# 定義
# ================================================================================
VAGRANTFILE_API_VERSION = "2" # 変更しない

# OSと対応するbox、対応するhttpdの定義
CENT_OS_6 = {
    'tag_os'    => 'CentOs6',
    'tag_httpd' => 'apache22',
    'box_name'  => 'hnakamur/centos6.5-x64'
}

CENT_OS_7 = {
    'tag_os'    => 'CentOs7',
    'tag_httpd' => 'apache24',
    'box_name'  => 'centos70',
    'box_url'   => 'https://f0fff3908f081cb6461b407be80daf97f07ac418.googledrive.com/host/0BwtuV7VyVTSkUG1PM3pCeDJ4dVE/centos7.box',
    'selinux'   => true
}


# ユーザー定義
# ================================================================================

# 下記はhostOSのhostsの設定と合わせる
IP_ADDRESS = "192.168.30.10"
HOST_NAME  = "develop.local"

# apacheのドキュメントルートになる
DOC_ROOT = "/vagrant/projectCode/webroot"

# 使用するOS設定
OS_TYPE = CENT_OS_6

# 使用するansible tags(OSとhttpdは自動設定)
# PLAY_TAGS = ['php56', 'mysql56']
PLAY_TAGS = []


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = OS_TYPE['box_name']
    if OS_TYPE.key?('box_url') then
        config.vm.box_url = OS_TYPE['box_url']
    end


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

        # 実行tags
        TAGS = [OS_TYPE['tag_os'], OS_TYPE['tag_httpd']]
        if OS_TYPE.key?('selinux') then
            TAGS = TAGS + ['SELinux']
        end
        TAGS = TAGS + PLAY_TAGS
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
