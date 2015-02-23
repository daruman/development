#!/usr/bin/env bash
#
# Provisioning shell
#
# ansibleが使用出来ないwindows用
# @args $1    インベントリファイルのホストグループ名、playbookで指定されているもの
# @args $2... これ以降の引数は全て`ansible-playbook`コマンドの引数
#
echo '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '
echo 'Provisioning shell start'
echo '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '

# ansible install
if ! [ `which ansible` ]; then
    sudo yum update
    sudo yum install -y epel-release
    sudo yum install -y ansible
fi


# get args
inventory_group=$1
args=''
while [ "$2" != "" ]
do
    opt=$2" "
    args=$args$opt
    shift
done


# make InventoryFile
sudo echo -e "[${inventory_group}]\nlocalhost ansible_connection=local\n" > /etc/ansible/hosts


# run
command="sudo ansible-playbook -i /etc/ansible/hosts ${args}"
echo $command
$command

