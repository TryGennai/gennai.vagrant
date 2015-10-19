# Getting started

Vagrantにて、[genn.ai](https://github.com/TryGennai/gennai)を容易に利用することができます。

## 目次

1. [アプリケーション](#application)
2. [サービス](#service)
3. [VMに関して](#vm)
4. [メモリ](#memory)
5. [Example](#example)

##<a name="application"></a>アプリケーション

このVagrantにてVMにインストールされるアプリケーションは下記の通りです。

|#|Application|Version|Install Directory|
|:--:|:--|:--|:--|
|1|JDK|1.7.0\_80|/usr/java/jdk1.7.0\_80|
|2|ZooKeeper|3.4.6|/opt/zookeeper-3.4.6|
|3|Kafka|0.8.2.1|/opt/kafka\_2.10-0.8.2.1|
|4|storm|0.9.4|/opt/apache-storm-0.9.4|
|5|GungnirServer|0.0.1|/opt/gungnir-server-0.0.1|
|6|GungnirClient|0.0.1|/opt/gungnir-client-0.0.1|

このうち、JDK, ZooKeeper, GungnirClientにはそれぞれPATHを通しています。

VM起動後、各サービスを起動すれば下記コマンドを実行する事ができます。
各サービスの起動方法に関しては[サービス](#service)を参照してください。

```
$ gungnir -u root -p gennai
```


##<a name='service'></a> サービス

各モードで利用されるアプリケーションは以下となり、全てサービス化しています。

|#|Service|起動/停止|主なログ|備考|
|:--:|:--|:--|:--|:--|
|1|ZooKeeper|sudo service zookeeper [start｜stop]|-|-|
|2|Kafka|sudo service kafka [start｜stop]|/opt/kafka/logs/server.log|-|
|3|MongoDB|sudo service mongod [start｜stop]|/var/log/mongodb/mongod.log|-|
|4|Storm nimbus|sudo service storm-nimbus [start｜stop]|/opt/storm/logs/nimbus.log|-|
|5|Storm supervisor|sudo service storm-supervisor [start｜stop]|/opt/storm/logs/supervisor.log|-|
|6|Storm UI|sudo service storm-ui [start｜stop]|-|※1,※2|
|7|Storm LogViewer|sudo service storm-logviewer [start｜stop]|-|※1|
|8|GungnirServer|sudo service gungnir-server [start｜stop]|/opt/gungnir-server/logs/gungnir.log|-|
|9|TupleStoreServer|sudo service tuple-store-server [start｜stop]|/opt/gungnir-server/logs/tuple-store-server.log||


* ※1: 自動起動対象外です。
* ※2: Storm UIは、http://[IP]:8080/に起動します。  


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

* [Simple example](https://github.com/TryGennai/gennai#simple-example)
* [各種サンプル](https://github.com/TryGennai/gennai.sample)
