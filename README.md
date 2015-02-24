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
- ansible (windowsは動かないので不要)


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

__使用済みIPとぶつからないように適時変更__
```
sudo echo '192.168.30.10   develop-env.local' >> /path/hosts
```

2. cloneして起動
--------------------------------------------------------------------------------

__初回は凄く時間がかかる、環境次第だけど10分以上はかかりそう__  
__hostsで使用するIPを変更した場合はVagrantFileも該当箇所修正__  

```
# 適当な箇所にclone
$ git clone git@github.com:daruman/development.git development_env
$ cd $_

# 起動+プロビジョニング+リロード(一応リロードしておく)
$ vagrant up && vagrant reload
```

windowsの場合、vm起動 -> vm上でshellでansibleインストール -> ansible実行なので  
コンソールへの出力がansible実行段階で停止…一気に出力、となるので気長に待つ


これをひな形として開発環境を作る
================================================================================

何らかのprojectの開発環境のひな形としてこのRepositoryを使う場合


ソース取得
--------------------------------------------------------------------------------

普通にcloneするとこのRepositoryの管理下になるので  
ダウンロードする、もしくは別のディレクトリに一旦cloneし
```
$ git archive HEAD --worktree-attributes -o archive.tgz
```
とかでアーカイブしてそれを使用projectディレクトリに持っていく。


設定変更箇所
--------------------------------------------------------------------------------

変更が必要な可能性のあるファイルは以下  
(開発環境としてなので、商用インベントリファイルの修正とかそゆのは含まない)

### Vagrantfile

ユーザー定義箇所を中心に必要に応じて  
主にipやhost名、使用tagの変更を行う事が多そう。

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
(destroy + upするのはpush前の確認のみで良い)
```
$ vagrant reload {対象サーバー名} # 必須
$ vagrant provision {対象サーバー名}
```

webserver等含んでいる場合はブラウザからの表示確認、  
dbを含んでいる場合はlogin確認の他、hostOSからのアクセス確認もしておくとよさそう。



Tips
================================================================================

webserverとdbserverの疎通確認
--------------------------------------------------------------------------------

```sh
# hostOSから
$ vagrant ssh webserver -c 'test_connectivity'
```



[1]: http://kashewnuts.bitbucket.org/2013/08/25/vagrantvbguest.html

