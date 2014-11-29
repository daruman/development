かいはつかんきょうつかいかた
================================================================================

Vagrantにplugin追加
--------------------------------------------------------------------------------

GuestOS次第では毎回軌道後`sudo /etc/init.d/vboxadd setup`としないとエラーが出るので
自動でやってくれるpluginを入れる

```
$ vagrant plugin install vagrant-vbguest
```

[Vagrant で共有フォルダが使用できなくなったので解決メモ — kashew_nuts-blog][1]



また、以下を追加しておくと何回もプロビジョニングする際に早くなって便利

```
$ vagrant plugin install vagrant-cachier
```

以下をVagrantfileに追加
```
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
```

また、キャッシュを`/var/cache/yum/x86_64/`に作るため、プロビジョニングの際x86_64ディレクトリを作成する必要がある。(設定済み)

[Vagrant のアーカイブ - Shin x blog](http://www.1x1.jp/blog/category/vagrant)



設定変更
--------------------------------------------------------------------------------

defaultは開発用に適当に設定されているので  
projectに合わせて以下を修正（主にhost名やドキュメントルート等の設定

- Vagrantfile
- ansible/playbook.yml
- ansible/vars/common.yml
- ansible/vars/mysql.yml

_ansible/hostsのIPは変更しない_

上記で設定したIPアドレスやサーバ名に合わせて、hostOSのhostsを編集


起動、プロビジョニング
--------------------------------------------------------------------------------

```
$ vagrant up

# SELinux設定変更を含むため、up後にreloadする
$ vagrant reload
```

プロビジョニング中にエラーした場合、解決後にプロビジョニングを再開する。
```
$ vagrant provision
```








[1]: http://kashewnuts.bitbucket.org/2013/08/25/vagrantvbguest.html

