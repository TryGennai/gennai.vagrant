# VMに関して

## 目次

1. [アプリケーション](#application)
2. [モード(mode)](#mode)
3. [config.yaml](#config)
4. [サービス](#service)
5. [VMに関して](#vm)
6. [メモリ](#memory)
7. [サンプル](#sample)



##<a name="application"></a>アプリケーション

インストールされるアプリケーションは下記の通りです。

|#|Application|Version|Install Directory|
|:--:|:--|:--|:--|
|1|JDK|1.6.0_45|/usr/java/jdk1.6.0_45|
|2|ZooKeeper|3.4.5|/opt/zookeeper-3.4.5|
|3|Kafka|0.8.0|/opt/kafka_2.8.0-0.8.0|
|4|storm|0.9.0.1|/opt/storm-0.9.0.1|
|5|GungnirServer|0.0.1|/opt/gungnir-server-0.0.1|
|6|GungnirClient|0.0.1|/opt/gungnir-client-0.0.1|

JDK, ZooKeeper, GungnirClientにはそれぞれPATHを通しています。

VM起動後、各サービスを起動すれば下記コマンドを実行する事ができます。  
各サービスの起動方法に関しては[サービス](#service)を参照してください。  

```
$ gungnir -u root -p gennai
```



##<a name="mode"></a>モード(mode)

下記3つのモードを設定する事ができます。モードによってインストールされるアプリケーションが異なります。

* [minimum](#minimummode)
* [local](#localmode)
* [distributed](#distributedmode)

デフォルトでは"distributed"モードで起動されます。モードの変更は[config.yaml](#config)で行います。

※ 現状では`vagrant up`後にmodeを変更しないでください。

###<a name="minimummode"></a>minimum mode

極簡易な動作確認等に用いるモードです。最低限の機能のみインストール・設定されます。  
インストールされるアプリケーションは下記の通りです。

|#|Application/Server|備考|
|:--:|:--|:--|
|1|Kafka|-|
|2|GungnirServer|InMemoryMetaStore|

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはInMemoryMetStoreで起動されます。従ってGungnirServerを停止するとメタ情報は削除されます。  
※ MongoDBはインストールされないので、EMIT句でmongo_persistを用いる事はできません。  
※ Kafkaに同梱されているZooKeeperを利用します。  

###<a name="localmode"></a>local mode

簡易な動作確認等に用いるモードです。StormをインストールせずGungnirServerをローカルモードで利用します。  
その為、分散処理は確認できませんが、GungnirServerの一通りの機能を試す事ができます。  

インストールされるアプリケーションは下記の通りです。

|#|Application/Service|備考|
|:--:|:--|:--|
|1|ZooKeeper|-|
|2|Kafka|-|
|3|MongoDB|-|
|4|GungnirServer|MongoDbMetaStore|

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはMongoDbMetaStoreを利用します。従って、GungnirServerを再起動してもめた情報は保持されます。

###<a name="distributedmode"></a>distributed mode

本番環境と同等の機能を確認する事ができるモードです。  
ただしCPU・割当メモリをデフォルト設定値より増強しておくのが望ましいです。([参照](#vm))

インストールされるアプリケーションは下記の通りです。

|#|Application/Service|備考|
|:--:|:--|:--|
|1|ZooKeeper|-|
|2|Kafka|-|
|3|MongoDB|-|
|4|Storm nimbus|-|
|5|Storm supervisor|-|
|6|Storm UI|-|
|7|Storm LogViewer|-|
|8|GungnirServer|MongoDbMetaStore|

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはMongoDbMetaStoreを利用します。従って、GungnirServerを再起動してもめた情報は保持されます。  
※ Storm UIは起動しなくても使用する事が可能です。  



##<a name="config"></a>config.yaml

`config.yaml`に各種設定を書く事ができます。

|Propertyless|Value|default Value|
|:--|:--|:--|:--|
|common.mode|[minimum](#minimummode)/[local](#localmod)/[distributed](#distributedmode)|distributed|
|common.hostname|[STRING]/off|off|
|common.sample|yes/no|no|
|zookeeper.install|true/false|true|
|zookeeper.dir|-|/opt|
|zookeeper.version|-|3.4.5|
|zookeeper.user|-|vagrant|
|zookeeper.group|-|vagrant|
|zookeeper.service|on/off|off|
|kafka.install|true/false|true|
|kafka.version|-|0.8.0|
|kafka.scala|-|2.8.0|
|kafka.user|-|vagrant|
|kafka.group|-|vagrant|
|kafka.service|on/off|off|
|mongodb.install|true/false|true|
|mongodb.service|on/off|off|
|storm.install|true/false|true|
|storm.dir|-|/opt|
|storm.version|-|0.9.0.1|
|storm.user|-|vagrant|
|storm.group|-|vagrant|
|storm.service|on/off|off|
|gungnir.install|true/false|true|
|gungnir.dir|-|/opt|
|gungnir.user|-|vagrant|
|gungnir.group|-|vagrant|
|gungnir.service|on/off|off|



##<a name='service'></a> サービス

下記はサービス化しています。

|#|Service|[minumum](#minimummode)|[local](#localmode)|[distributed](#distributedmode)|備考|
|:--:|:--|:--|:--:|:--:|:--|
|1|ZooKeeper|-|○|○|※1|
|2|Kafka|○|○|○||
|3|MongoDB|-|○|○|※2|
|4|Storm nimbus|-|-|○|※3|
|5|Storm supervisor|-|-|○|※3|
|6|Storm UI|-|-|-|※3,※4|
|7|Storm LogViewer|-|-|-|※3,※5|
|8|GungnirServer|○|○|○||

※1: Kafkaに同梱されているZooKeeperを利用します。  
※2: GungnirServerはInMemoryMetaStoreを用いる為、MongoDBをインストールしません。  
※3: distributedモードの場合のみインストールされます。  
※4: `sudo service storm-ui start`で起動してください。  config.yamlでservice=trueとしてもUIは起動対象外です。  
※5: `sudo service storm-logviewer start`で起動してください。config.yamlでservice=trueとしてもLogViewerは対象外です。  

各種サービスの起動と停止は下記を参照してください。

###<a name="zookeeper"></a> ZooKeeper

```
$ sudo service zookeeper [start|stop]
```

###<a name="kafka"></a> Kafka

```
$ sudo service kafka [start|stop]
```

###<a name="mongodb"></a> MongoDB

```
$ sudo service mongod [start|stop]
```

###<a name="nimbus"></a> Storm nimbus

```
$ sudo service storm-nimbus [start|stop]
```

###<a name="supervisor"></a> Storm supervisor

```
$ sudo service storm-supervisor [start|stop]
```

###<a name="ui"></a> Storm UI

```
$ sudo service storm-ui [start|stop]
```

###<a name="logviewer"></a> Storm LogViewer

```
$ sudo service storm-logviewer [start|stop]
```

###<a name="gungnir"></a> GungnirServer

```
$ sudo service gungnir-server [start|stop]
```



##<a name='vm'></a> VMに関して

現時点ではメモリは各種フォルト設定で起動されています。  
よって重い処理を実行するとメモリが足りなくなる恐れがあります。  

Vagrantfileを編集し、VMのメモリ容量・CPU数を起動するホストマシンの性能によって調整してください。

```
  virtualbox.memory=2048
  virtualbox.cpus = 2
```



##<a name='memory'></a> メモリ設定

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
|8|GungnirClient|実メモリの1/4|実メモリの1/64|

### mode: minimum

|#|Application|Xmx|Xms|
|:--:|:--|--:|--:|
|1|Kafka|1G|1G|
|2|GungnirServer|実メモリの1/4|実メモリの1/64|
|3|GungnirClient|実メモリの1/4|実メモリの1/64|


### mode: local

|#|Application|Xmx|Xms|
|:--:|:--|--:|--:|
|1|ZooKeeper|実メモリの1/4|実メモリの1/64|
|2|Kafka|1G|1G|
|3|GungnirServer|実メモリの1/4|実メモリの1/64|
|4|GungnirClient|実メモリの1/4|実メモリの1/64|

### mode: distributed

|#|Application|Xmx|Xms|
|:--:|:--|--:|--:|
|1|ZooKeeper|実メモリの1/4|実メモリの1/64|
|2|Kafka|1G|1G|
|3|Storm nimbus|1024M|実メモリの1/64|
|4|Storm supervisor|256M|実メモリの1/64|
|5|Storm worker|768M|実メモリの1/64|
|6|GungnirServer|実メモリの1/4|実メモリの1/64|
|7|GungnirClient|実メモリの1/4|実メモリの1/64|

##<a name="sample"></a> サンプル

[config.yaml](#config)にて下記の記述をするとサンプルをVMに配置し、実行する事ができます。

```
[common]
sample=yes
```

サンプルはホームディレクトリにsampleディレクトリを作成し、いくつかのqueryを配置します。また、gennaiユーザを事前に作成しますので、VM起動後は即下記コマンドを実行する事が可能です。

```
$ gungnir -u gennai -p gennai
```

