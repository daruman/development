# -*- mode: ruby -*-
# vi: set ft=ruby :
require "json"

# 定義
# ================================================================================

# 変更しない
VAGRANTFILE_API_VERSION = "2" if !defined? VAGRANTFILE_API_VERSION

# OSと対応するbox、対応するhttpdの定義
CENT_OS_6 = {
    'tag_os'    => 'CentOs6',
    'tag_httpd' => 'apache22',
    'box_name'  => 'opscode_centos-6.6',
    'box_url'   => 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.6_chef-provisionerless.box',
}
CENT_OS_7 = {
    'tag_os'    => 'CentOs7',
    'tag_httpd' => 'apache24',
    'box_name'  => 'opscode_centos-7.0',
    'box_url'   => 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-7.0_chef-provisionerless.box',
}

# windows判別
IS_WINDOWS = false
if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    IS_WINDOWS = true
end


# Configuration
# ================================================================================
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # ユーザー定義
    # --------------------------------------------------------------------------------

    # 作成されるvirtualboxのマシン名
    $WEB_MACHINE_NAME  = 'env_web_server'
    $DB_MACHINE_NAME   = 'env_db_server'
    $TOOL_MACHINE_NAME = 'env_tool_server'

    # 下記はhostOSのhostsの設定と合わせる(ただしapacheを置かないdbサーバ等のhost名はdummyで良い)
    $WEB_SERVER_IP_ADDRESS  = "192.168.30.10"
    $DB_SERVER_IP_ADDRESS   = "192.168.30.11"
    $TOOL_SERVER_IP_ADDRESS = "192.168.30.12"
    $WEB_SERVER_HOST_NAME   = "develop-env.local"
    $DB_SERVER_HOST_NAME    = "develop-env-db.local"
    $TOOL_SERVER_HOST_NAME  = "develop-tool.local"

    # apacheのドキュメントルートになる
    $WEB_SERVER_DOC_ROOT = "/vagrant/projectCode/webroot"

    # 使用するOS設定
    $WEB_SERVER_OS_TYPE  = CENT_OS_6
    $DB_SERVER_OS_TYPE   = CENT_OS_6
    $TOOL_SERVER_OS_TYPE = CENT_OS_6

    # 使用するansible tags(OSとhttpdは自動設定)
    # $WEB_SERVER_PLAY_TAGS = ['php56', 'web_project']
    # $DB_SERVER_PLAY_TAGS = ['mysql56', 'db_project']
    $WEB_SERVER_PLAY_TAGS  = ['php56']
    $DB_SERVER_PLAY_TAGS   = ['mysql56']
    $TOOL_SERVER_PLAY_TAGS = ['frontend_devtool', 'ruby']




    # box
    # --------------------------------------------------------------------------------
    # (全てのサーバのOSが同じなら)どれでも良いのでwebの設定を使用
    config.vm.box = $WEB_SERVER_OS_TYPE['box_name']
    if $WEB_SERVER_OS_TYPE.key?('box_url') then
        config.vm.box_url = $WEB_SERVER_OS_TYPE['box_url']
    end


    # server
    # --------------------------------------------------------------------------------
    # 建てるサーバが1つでも、以下のdefineがないと自動生成されるvagrant_ansible_inventoryに
    # 出力されるサーバ設定用変数名が`default`になってしまう

    # webserver
    config.vm.define "webserver" do |webserver|
        webserver.vm.hostname = $WEB_SERVER_HOST_NAME
        webserver.vm.network :private_network, ip: $WEB_SERVER_IP_ADDRESS
        webserver.ssh.forward_agent = true

        webserver.vm.provider :virtualbox do |v|
            # virtualboxのGUI上の名前変更
            v.name = $WEB_MACHINE_NAME

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
            web_server_tags = [$WEB_SERVER_OS_TYPE['tag_os'], $WEB_SERVER_OS_TYPE['tag_httpd']] + $WEB_SERVER_PLAY_TAGS
            if $WEB_SERVER_OS_TYPE.key?('selinux') then
                web_server_tags = web_server_tags + ['SELinux']
            end
            ansible.tags = web_server_tags.join(',')

            ansible.extra_vars = {
                'servername'    => $WEB_SERVER_HOST_NAME,
                'ip_address'    => $WEB_SERVER_IP_ADDRESS,
                'db_servername' => $DB_SERVER_HOST_NAME,
                'db_ip_address' => $DB_SERVER_IP_ADDRESS,
                'doc_root'      => $WEB_SERVER_DOC_ROOT
            }

            # debug用
            # ansible.verbose =  'vvvv'
        end
    end

    # db server
    config.vm.define "dbserver" do |dbserver|
        dbserver.vm.hostname = $DB_SERVER_HOST_NAME
        dbserver.vm.network :private_network, ip: $DB_SERVER_IP_ADDRESS
        dbserver.ssh.forward_agent = true

        dbserver.vm.provider :virtualbox do |v|
            # virtualboxのGUI上の名前変更
            v.name = $DB_MACHINE_NAME

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
            db_server_tags = [$DB_SERVER_OS_TYPE['tag_os']] + $DB_SERVER_PLAY_TAGS
            if $DB_SERVER_OS_TYPE.key?('selinux') then
                db_server_tags = db_server_tags + ['SELinux']
            end
            ansible.tags = db_server_tags.join(',')

            ansible.extra_vars = {
                'servername'     => $DB_SERVER_HOST_NAME,
                'ip_address'     => $DB_SERVER_IP_ADDRESS,
                'web_servername' => $WEB_SERVER_HOST_NAME,
                'web_ip_address' => $WEB_SERVER_IP_ADDRESS,
            }

            # debug用
            # ansible.verbose =  'vvvv'
        end
    end

    # toolserver
    config.vm.define "toolserver" do |toolserver|
        toolserver.vm.hostname = $TOOL_SERVER_HOST_NAME
        toolserver.vm.network :private_network, ip: $TOOL_SERVER_IP_ADDRESS
        toolserver.ssh.forward_agent = true

        toolserver.vm.provider :virtualbox do |v|
            # virtualboxのGUI上の名前変更
            v.name = $TOOL_MACHINE_NAME

            # 割り当てメモリ変更
            v.customize ["modifyvm", :id, "--memory", 1024]
        end

        # provision
        # --------------------------------------------------------------------------------
        toolserver.vm.provision "ansible" do |ansible|
            # vagrantが自動生成するものを使用するのでインベントリファイルは指定しない

            ansible.limit = 'toolserver'
            ansible.playbook = 'ansible/start.yml'

            # hostOSの~/.ssh/known_hostsに書き込まない
            ansible.host_key_checking = false

            # 実行tags
            tool_server_tags = [$TOOL_SERVER_OS_TYPE['tag_os']] + $TOOL_SERVER_PLAY_TAGS
            if $TOOL_SERVER_OS_TYPE.key?('selinux') then
                tool_server_tags = tool_server_tags + ['SELinux']
            end
            ansible.tags = tool_server_tags.join(',')

            ansible.extra_vars = {
                'servername'    => $TOOL_SERVER_HOST_NAME,
                'ip_address'    => $TOOL_SERVER_IP_ADDRESS,
            }

            # debug用
            # ansible.verbose =  'vvvv'
        end
    end
end
