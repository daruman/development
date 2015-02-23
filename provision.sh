#!/usr/bin/env bash
# @todo 何故かコケる

if ! [ `which ansible` ]; then
    sudo yum update
    sudo yum install -y epel-release
    sudo yum install -y ansible
fi

args=''
while [ "$1" != "" ]
do
    echo $1
    args=' '${args}$1
    shift
done


command='ansible-playbook -i /vagrant/ansible/local '$args
echo $command

# run
$command


