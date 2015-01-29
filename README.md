前提
================================================================================

`virtualbox` + `vagrant` + `ansible`による開発環境ひながた  

ansibleに関しては主にこれをベースに構成  
[Best Practices — Ansible Documentation](http://docs.ansible.com/playbooks_best_practices.html)  


事前準備
--------------------------------------------------------------------------------

以下を使えるようにしておく

- virtualbox
- vagrant
- ansible

Vagrantにplugin追加
--------------------------------------------------------------------------------

GuestOS次第では毎回起動後`sudo /etc/init.d/vboxadd setup`としないとエラーが出るので、  
自動でやってくれるpluginをvagrantに追加する

```
$ vagrant plugin install vagrant-vbguest
```

参考: [Vagrant で共有フォルダが使用できなくなったので解決メモ — kashew_nuts-blog][1]



通常の使用方法(初回、そのまま使用)
================================================================================

インフラに特に制限がない段階で既存の設定のままテスト使用する場合。

1. hostsに追加
--------------------------------------------------------------------------------

```
sudo echo '192.168.30.10   develop-env.local' >> /path/hosts
```

2. cloneして起動
--------------------------------------------------------------------------------

__初回は凄く時間がかかる、環境次第だけど10分以上はかかりそう__

```
# 適当な箇所にclone
$ git clone git@github.com:daruman/development.git development_env
$ cd $_

# 起動+プロビジョニング
$ vagrant up

# SELinux設定変更を含む場合、up後にreloadする(対応されていないboxを使用する場合)
# $ vagrant reload
```


これをひな形として開発環境を作る
================================================================================

何らかのprojectの開発環境のひな形としてこのRepositoryを使う場合

設定変更箇所
--------------------------------------------------------------------------------

変更が必要な可能性のあるファイルは以下  
(開発環境としてなので、商用インベントリファイルの修正とかそゆのは含まない)

### Vagrantfile

ユーザー定義箇所を中心に必要に応じて

### playbook

起点となる`ansible/start.yml`及び、そこから呼ばれる子playbookにて  
実行するroleを選択する。

### role

必要があれば新たにroleを作成し追加する。  
また、project特有のインストレーション等があれば以下のように追加する。
1. project用playbookを作成
2. 上記playbookをstart.ymlに追加し、呼び出されるようにする
3. ansible/roles配下にproject用role配置ディレクトリを作成、その中にtaskを実装する
4. 実装したタスク全てに任意のタグを設定する
5. VagrantFileで実行するタグ配列に上記タグ名を追加する

既存のrole等を参考にすれば多分だいじょうぶ

設定実装中の動作確認
--------------------------------------------------------------------------------

プロビジョニング中のエラー修正後や、既にVMが起動している場合、  
以下の手順でプロビジョニングを再開する。  
(destroy + upするのはキリの良いタイミングでの確認のみで良い)
```
$ vagrant reload {対象サーバー名} # 必須
$ vagrant provision {対象サーバー名}
```

webserver等含んでいる場合はブラウザからの表示確認、  
dbを含んでいる場合はlogin確認の他、hostOSからのアクセス確認もしておくとよさそう。




[1]: http://kashewnuts.bitbucket.org/2013/08/25/vagrantvbguest.html

