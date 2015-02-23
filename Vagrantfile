# -*- mode: ruby -*-
# vi: set ft=ruby :
require "json"

# 定数
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
    #
    # | inventory_group |
    # | machine_name    | 作成されるvirtualboxのマシン名
    # | ip_address      | hostOSのhostsの設定と合わせる(apacheを置かないdbサーバ等のhost名はdummyで良い)
    # | host_name       | apacheのドキュメントルートになる
    # | os_setting      | 使用するOS設定(定数参照)
    # | ansible_tags    | 使用するansible tags(OSとhttpdは自動設定)[etc. php56,web_project,mysql56,db_project]
    # | playbook        | 基本変更する必要無し
    #
    # --------------------------------------------------------------------------------
    server_configs = {
        'webserver' => {
            'inventory_group' => 'webservers',
            'machine_name'    => 'env_web_server',
            'ip_address'      => '192.168.30.10',
            'host_name'       => 'develop-env.local',
            'doc_root'        => '/vagrant/projectCode/webroot',
            'os_setting'      => CENT_OS_6,
            'ansible_tags'    => ['php56'],
            'playbook'        => 'ansible/start.yml',
        },
        'dbserver' =>{
            'inventory_group' => 'dbservers',
            'machine_name'    => 'env_db_server',
            'ip_address'      => '192.168.30.11',
            'host_name'       => 'develop-env-db.local',
            'os_setting'      => CENT_OS_6,
            'ansible_tags'    => ['mysql56'],
            'playbook'        => 'ansible/start.yml',
        },
        'toolserver' => {
            'inventory_group' => 'toolservers',
            'machine_name'    => 'env_tool_server',
            'ip_address'      => '192.168.30.12',
            'host_name'       => 'develop-env-tool.local',
            'os_setting'      => CENT_OS_6,
            'ansible_tags'    => ['frontend_devtool', 'ruby'],
            'playbook'        => 'ansible/start.yml',
        },
    }

    server_configs.each do |host, server_config|
        config.vm.box = server_config['os_setting']['box_name']
        if server_config['os_setting'].key?('box_url') then
            config.vm.box = server_config['os_setting']['box_url']
        end

        # ansibleに渡す値
        extra_vars = {
            'servername' => server_config['host_name'],
            'ip_address' => server_config['ip_address'],
            'doc_root'   => server_config['doc_root'],
        }
        if host == 'webserver' then
            extra_vars['db_servername'] = server_configs['dbserver']['host_name']
            extra_vars['db_ip_address'] = server_configs['dbserver']['ip_address']
        elsif host == 'dbserver' then
            extra_vars['web_servername'] = server_configs['webserver']['host_name']
            extra_vars['web_ip_address'] = server_configs['webserver']['ip_address']
        end

        # 実行tags
        os_setting = server_config['os_setting']
        tags = [os_setting['tag_os'], os_setting['tag_httpd']] + server_config['ansible_tags']
        if os_setting.key?('selinux') then
            tags = tags + ['SELinux']
        end

        config.vm.define host do |server|
            server.vm.hostname = server_config['host_name']
            server.vm.network :private_network, ip: server_config['ip_address']
            server.ssh.forward_agent = true

            server.vm.provider :virtualbox do |v|
                # virtualboxのGUI上の名前変更
                v.name = server_config['machine_name']

                # 割り当てメモリ変更
                v.customize ["modifyvm", :id, "--memory", 1024]
            end

            if IS_WINDOWS then
                provisionByShell(server, host, server_config, extra_vars, tags, server_config['playbook'])
            else
                provisionByAnsible(server, host, server_config, extra_vars, tags, server_config['playbook'])
            end
        end

    end
end





#
# ansibleによるProvisioning
#
def provisionByAnsible(server, host, server_config, extra_vars, tags, playbook)
    server.vm.provision "ansible" do |ansible|
        # vagrantが自動生成するものを使用するのでインベントリファイルは指定しない

        ansible.groups = { server_config['inventory_group'] => host }
        ansible.limit = server_config['inventory_group']
        ansible.playbook = playbook

        # hostOSの~/.ssh/known_hostsに書き込まない
        ansible.host_key_checking = false

        ansible.tags = tags.join(',')
        ansible.extra_vars = extra_vars

        # debug用
        # ansible.verbose =  'vvvv'
    end
end


#
# shellによるProvisioning
# windows用
#
def provisionByShell(server, host, server_config, extra_vars, tags, playbook)
    server.vm.provision "shell" do |shell|
        limit = server_config['inventory_group']
        args = [
            limit,
            '--limit=' + limit,
            '--tags=' + tags.join(','),
            '--extra-vars=' + extra_vars.to_json,
            '/vagrant/' + playbook
        ]

        shell.args = args
        shell.path = 'provision.sh'
    end
end
