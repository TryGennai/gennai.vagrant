# Getting started

Vagrantにて、[genn.ai](https://github.com/TryGennai/gennai)を容易に利用することができます。

## 目次

1. [アプリケーション](#application)
2. [モード(mode)](#mode)
3. [config.yaml](#config)
4. [サービス](#service)
5. [VMに関して](#vm)
6. [メモリ](#memory)
7. [Example](#example)

##<a name="application"></a>アプリケーション

このVagrantにてVMにインストールされるアプリケーションは下記の通りです。

|#|Application|Version|Install Directory|
|:--:|:--|:--|:--|
|1|JDK|1.7.0_71|/usr/java/jdk1.7.0_71|
|2|ZooKeeper|3.4.5|/opt/zookeeper-3.4.5|
|3|Kafka|0.8.1.1|/opt/kafka_2.10-0.8.1.1|
|4|storm|0.9.2|/opt/apache-storm-0.9.2-incubating|
|5|GungnirServer|0.0.1|/opt/gungnir-server-0.0.1|
|6|GungnirClient|0.0.1|/opt/gungnir-client-0.0.1|

このうち、JDK, ZooKeeper, GungnirClientにはそれぞれPATHを通しています。

VM起動後、各サービスを起動すれば下記コマンドを実行する事ができます。
各サービスの起動方法に関しては[サービス](#service)を参照してください。

```
$ gungnir -u root -p gennai
```


##<a name="mode"></a>モードの設定

下記3つのモードを設定する事ができます。
モードの変更は[config.yaml](#config)を編集することで行います。
モードによって利用されるアプリケーションが異なります。

* [minimum](#minimummode)
* [local](#localmode)
* [distributed](#distributedmode)　/* デフォルト */

※ `vagrant up`後にmodeを変更しないでください。  
※ Storm UI、Storm LogViewerはデフォルトでは起動しません。必要に応じて起動して下さい。  

###<a name="minimummode"></a>minimum mode

極簡易な動作確認等に用いるモードです。最低限の機能のみインストール・設定されます。

`vagrant up`後、各種サービスを起動し、genn.aiを使用する事が可能です。

※ GungnirServerはInMemoryMetaStoreで起動されます。従ってGungnirServerを停止するとメタ情報は削除されます。  
※ MongoDBはインストールされないので、JOIN句でmongo_fetch、EMIT句でmongo_persistを用いる事はできません。  
※ Kafkaに同梱されているZooKeeperを利用します。  

###<a name="localmode"></a>local mode

簡易な動作確認等に用いるモードです。
Stormを起動せずGungnirServerをローカルモードで利用します。
その為、分散処理は確認できませんが、genn.aiについて一通りの機能を試す事ができます。

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはMongoDbMetaStoreを利用します。従って、GungnirServerを再起動してもメタ情報は保持されます。

###<a name="distributedmode"></a>distributed mode

本番環境と同等の機能を確認する事ができるモードです。
このモードを使う場合、CPU・割当メモリのデフォルト設定値を増強しておくのが望ましいです。([参照](#vm))

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはMongoDbMetaStoreを利用します。従って、GungnirServerを再起動してもメタ情報は保持されます。

##<a name='service'></a> サービス

各モードで利用されるアプリケーションは以下となり、全てサービス化しています。

|#|Service|[minumum](#minimummode)|[local](#localmode)|[distributed](#distributedmode)|起動/停止|主なログ|備考|
|:--:|:--|:--|:--:|:--:|:--|:--|:--|
|1|ZooKeeper|-|○|○|sudo service zookeeper [start｜stop]|-|※1|
|2|Kafka|○|○|○|sudo service kafka [start｜stop]|/opt/kafka/logs/server.log|-|
|3|MongoDB|-|○|○|sudo service mongod [start｜stop]|/var/log/mongodb/mongod.log|※2|
|4|Storm nimbus|-|-|○|sudo service storm-nimbus [start｜stop]|/opt/storm/logs/nimbus.log|※3|
|5|Storm supervisor|-|-|○|sudo service storm-supervisor [start｜stop]|/opt/storm/logs/supervisor.log|※3|
|6|Storm UI|-|-|-|sudo service storm-ui [start｜stop]|-|※3,※4|
|7|Storm LogViewer|-|-|-|sudo service storm-logviewer [start｜stop]|-|※3,※5,※6|
|8|GungnirServer|○|○|○|sudo service gungnir-server [start｜stop]|/opt/gungnir-server/logs/gungnir.log|-|
|9|TupleStoreServer|-|-|-|sudo service tuple-store-server [start｜stop]|/opt/gungnir-server/logs/tuple-store-server.log|※3,※7,※8|


※1: Kafkaに同梱されているZooKeeperを利用します。  
※2: GungnirServerはInMemoryMetaStoreを用いる為、MongoDBをインストールしません。  
※3: distributedモードの場合のみインストールされます。  
※4: `sudo service storm-ui start`で起動してください。config.yamlでservice=trueとしてもUIは起動対象外です。  
※5: `sudo service storm-logviewer start`で起動してください。config.yamlでservice=trueとしてもLogViewerは対象外です。  
※6: Storm UIは、同Vagrantの場合は[http://internal-vagrant.genn.ai:8080/](http://internal-vagrant.genn.ai:8080/)に上がります。  
※7: distributedモードの場合のみ、RESTサーバ機能をGungnirServerと分離し、別プロセスTupleStoreServerとして起動することができます。  
※8: 初期状態ではGungnirServerと同プロセスで起動される為、別プロセスで起動するには設定ファイルを変更する必要があります。  



##<a name="config"></a>config.yaml

`config.yaml`に各種設定を書く事ができます。

|Propertyless|Value|default Value|
|:--|:--|:--|:--|
|common.mode|[minimum](#minimummode)｜[local](#localmod)｜[distributed](#distributedmode)|distributed|
|common.sample|yes/no|no|
|zookeeper.install|true/false|true|
|zookeeper.dir|-|/opt|
|zookeeper.version|-|3.4.5|
|zookeeper.user|-|vagrant|
|zookeeper.group|-|vagrant|
|zookeeper.service|on/off|off|
|kafka.install|true/false|true|
|kafka.version|-|0.8.1.1|
|kafka.scala|-|2.10|
|kafka.user|-|vagrant|
|kafka.group|-|vagrant|
|kafka.service|on/off|off|
|mongodb.install|true/false|true|
|mongodb.service|on/off|off|
|storm.install|true/false|true|
|storm.dir|-|/opt|
|storm.version|-|0.9.2-incubating|
|storm.user|-|vagrant|
|storm.group|-|vagrant|
|storm.service|on/off|off|
|gungnir.install|true/false|true|
|gungnir.dir|-|/opt|
|gungnir.user|-|vagrant|
|gungnir.group|-|vagrant|
|gungnir.service|on/off|off|


##<a name='vm'></a> VMの設定

現時点ではVM自体のメモリは各種デフォルト設定で起動されている為、重い処理を実行するとメモリが足りなくなる恐れがあります。

必要に応じてVagrantfileを編集し、VMのメモリ容量・CPU数を起動するホストマシンの性能によって調整してください。

```
  virtualbox.memory=2048
  virtualbox.cpus = 2
```

VMはDHCPによってIPを振られています。固定IPを割り振るには下記を参考に編集してください。

```
  config.vm.network :private_network, ip: "192.168.30.10"
```


##<a name='memory'></a> アプリケーションのメモリ設定

メモリの設定を行います。

※ 実メモリの1/4, 実メモリの1/64はJDKのデフォルト設定です。


### Default設定

|#|Application|Xmx|Xms|
|:--:|:--|--:|--:|
|1|ZooKeeper|実メモリの1/4|実メモリの1/64|
|2|Kafka|1G|1G|
|3|Storm nimbus|1024M|実メモリの1/64|
|4|Storm supervisor|256M|実メモリの1/64|
|5|Storm worker|768M|実メモリの1/64|
|6|Storm UI|768M|実メモリの1/64|
|7|GungnirServer|実メモリの1/4|実メモリの1/64|
|8|GungnirClient|1024M|実メモリの1/64|
|9|TupleStoreServer|1024M|実メモリの1/64|


##<a name='example'></a> Example

下記を参照してください。genn.aiの使い方、タプルやクエリの例を記載しています。

* [Simple example](https://github.com/TryGennai/gennai.vagrant#simple-example)
* [各種サンプル](https://github.com/TryGennai/gennai.sample)
