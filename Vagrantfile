# -*- mode: ruby -*-
# vi: set ft=ruby :

# 定義
# ================================================================================
VAGRANTFILE_API_VERSION = "2" # 変更しない

# OSと対応するbox、対応するhttpdの定義
CENT_OS_6 = {
    'tag_os'    => 'CentOs6',
    'tag_httpd' => 'apache22',
    'box_name'  => 'hnakamur/centos6.5-x64',
}

CENT_OS_7 = {
    'tag_os'    => 'CentOs7',
    'tag_httpd' => 'apache24',
    'box_name'  => 'centos70',
    'box_url'   => 'https://f0fff3908f081cb6461b407be80daf97f07ac418.googledrive.com/host/0BwtuV7VyVTSkUG1PM3pCeDJ4dVE/centos7.box',
    'selinux'   => true,
}


# ユーザー定義
# ================================================================================

# 作成されるvirtualboxのマシン名
WEB_MACHINE_NAME = 'env_web_server'
DB_MACHINE_NAME = 'env_db_server'

# 下記はhostOSのhostsの設定と合わせる(ただしapacheを置かないdbサーバ等のhost名はdummyで良い)
WEB_SERVER_IP_ADDRESS = "192.168.30.10"
DB_SERVER_IP_ADDRESS = "192.168.30.11"
WEB_SERVER_HOST_NAME  = "develop-env.local"
DB_SERVER_HOST_NAME  = "develop-env-db.local"

# apacheのドキュメントルートになる
WEB_SERVER_DOC_ROOT = "/vagrant/projectCode/webroot"

# 使用するOS設定
WEB_SERVER_OS_TYPE = CENT_OS_6
DB_SERVER_OS_TYPE = CENT_OS_6

# 使用するansible tags(OSとhttpdは自動設定)
# WEB_SERVER_PLAY_TAGS = ['php56', 'web_project']
# DB_SERVER_PLAY_TAGS = ['mysql56', 'db_project']
WEB_SERVER_PLAY_TAGS = ['php56']
DB_SERVER_PLAY_TAGS = ['mysql56']


# Configuration
# ================================================================================
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # box
    # --------------------------------------------------------------------------------
    config.vm.box = WEB_SERVER_OS_TYPE['box_name']
    if WEB_SERVER_OS_TYPE.key?('box_url') then
        config.vm.box_url = WEB_SERVER_OS_TYPE['box_url']
    end


    # server
    # --------------------------------------------------------------------------------
    # 建てるサーバが1つでも、以下のdefineがないと自動生成されるvagrant_ansible_inventoryに
    # 出力されるサーバ設定用変数名が`default`になってしまう

    # webserver
    config.vm.define "webserver" do |webserver|
        webserver.vm.hostname = WEB_SERVER_HOST_NAME
        webserver.vm.network :private_network, ip: WEB_SERVER_IP_ADDRESS
        webserver.ssh.forward_agent = true

        webserver.vm.provider :virtualbox do |v|
            # virtualboxのGUI上の名前変更
            v.name = WEB_MACHINE_NAME

            # 割り当てメモリ変更
            v.customize ["modifyvm", :id, "--memory", 1024]
        end

        # provision
        # --------------------------------------------------------------------------------
        webserver.vm.provision "ansible" do |ansible|
            # vagrantが自動生成するものを使用するのでインベントリファイルは指定しない

            ansible.groups = { "webservers" => ["webserver"] }
            ansible.limit = 'webservers'
            ansible.playbook = 'ansible/start.yml'

            # hostOSの~/.ssh/known_hostsに書き込まない
            ansible.host_key_checking = false

            # 実行tags
            web_server_tags = [WEB_SERVER_OS_TYPE['tag_os'], WEB_SERVER_OS_TYPE['tag_httpd']] + WEB_SERVER_PLAY_TAGS
            if WEB_SERVER_OS_TYPE.key?('selinux') then
                web_server_tags = web_server_tags + ['SELinux']
            end
            ansible.tags = web_server_tags.join(',')

            ansible.extra_vars = {
                'servername'    => WEB_SERVER_HOST_NAME,
                'ip_address'    => WEB_SERVER_IP_ADDRESS,
                'db_servername' => DB_SERVER_HOST_NAME,
                'db_ip_address' => DB_SERVER_IP_ADDRESS,
                'doc_root'      => WEB_SERVER_DOC_ROOT
            }

            # debug用
            # ansible.verbose =  'vvvv'
        end
    end

    # db server
    config.vm.define "dbserver" do |dbserver|
        dbserver.vm.hostname = DB_SERVER_HOST_NAME
        dbserver.vm.network :private_network, ip: DB_SERVER_IP_ADDRESS
        dbserver.ssh.forward_agent = true

        dbserver.vm.provider :virtualbox do |v|
            # virtualboxのGUI上の名前変更
            v.name = DB_MACHINE_NAME

            # 割り当てメモリ変更
            v.customize ["modifyvm", :id, "--memory", 1024]
        end

        # provision
        # --------------------------------------------------------------------------------
        dbserver.vm.provision "ansible" do |ansible|
            # vagrantが自動生成するものを使用するのでインベントリファイルは指定しない

            ansible.groups = { "dbservers" => ["dbserver"] }
            ansible.limit = 'dbservers'
            ansible.playbook = 'ansible/start.yml'

            # hostOSの~/.ssh/known_hostsに書き込まない
            ansible.host_key_checking = false

            # 実行tags
            db_server_tags = [DB_SERVER_OS_TYPE['tag_os']] + DB_SERVER_PLAY_TAGS
            if DB_SERVER_OS_TYPE.key?('selinux') then
                db_server_tags = db_server_tags + ['SELinux']
            end
            ansible.tags = db_server_tags.join(',')

            ansible.extra_vars = {
                'servername'     => DB_SERVER_HOST_NAME,
                'ip_address'     => DB_SERVER_IP_ADDRESS,
                'web_servername' => WEB_SERVER_HOST_NAME,
                'web_ip_address' => WEB_SERVER_IP_ADDRESS,
            }

            # debug用
            # ansible.verbose =  'vvvv'
        end
    end
end
