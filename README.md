

virtualbox + vagrant + ansible  

ansibleに関しては主にこれをベースに構成
[Best Practices — Ansible Documentation](http://docs.ansible.com/playbooks_best_practices.html)





事前準備
================================================================================

使う際に共通で行う事前準備

Vagrantにplugin追加
--------------------------------------------------------------------------------

GuestOS次第では毎回起動後`sudo /etc/init.d/vboxadd setup`としないとエラーが出るので、  
自動でやってくれるpluginを入れる

```
$ vagrant plugin install vagrant-vbguest
```

[Vagrant で共有フォルダが使用できなくなったので解決メモ — kashew_nuts-blog][1]






通常の使用方法
================================================================================

すぐに使う
--------------------------------------------------------------------------------

設定をいじってから使う
--------------------------------------------------------------------------------

Vagrantfileやansibleの設定をいじったら、以下の手順で起動し各種動作確認。

```
# 起動+プロビジョニング
$ vagrant up

# SELinux設定変更を含む場合、up後にreloadする
$ vagrant reload
```

プロビジョニング中にエラーした場合、解決後にプロビジョニングを再開する。
```
$ vagrant provision
```

webserver等含んでいる場合はブラウザからの表示確認、  
dbを含んでいる場合はlogin確認の他、hostOSからのアクセス確認をしておく。



ひな形として使う
================================================================================

何らかのprojectの開発環境として、ひな形としてこのRepositoryを使う場合

設定変更
--------------------------------------------------------------------------------

defaultは開発用に適当に設定されているので  
projectに合わせて必要に応じて以下を修正（主にhost名やドキュメントルート等の設定  
(デプロイ用にも出来るけどよくよく精査する必要があるんで今んとこ考えてない)


- Vagrantfile
- インベントリファイル
    - ansible/local
- playbook
    - ansible/site.yml
    - ansible/project.yml
その他、projectに合わせた内容を`ansible/role/project`に作っていく。  
OSやミドルウェアをあわせる必要があれば`ansible/group_vars/`の変数、  
それで足りなければ`ansible/role/common`ほか、いじっていく。

ただし、基本的に_ansible/localのIPは変更しない_



[1]: http://kashewnuts.bitbucket.org/2013/08/25/vagrantvbguest.html

