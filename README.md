# VMに関して

## 目次

1. [アプリケーション](#application)
2. [モード(mode)](#mode)
3. [config.ini](#config)
4. [サービス](#service)
5. [VMに関して](#vm)
6. [メモリ](#memory)



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

下記2つのモードを設定する事ができます。モードによってインストールされるアプリケーションが異なります。

* local
* distributed

デフォルトでは"distributed"モードで起動されます。モードの変更は[config.ini](#config)で行います。

※ 現状では`vagrant up`後にmodeを変更しないでください。

###<a name="localmode"></a>local mode

インストールされるアプリケーションは下記の通りです。

|#|Application/Service|
|:--:|:--|
|1|ZooKeeper|
|2|Kafka|
|3|MongoDB|
|4|GungnirServer|

`vagrant up`後、各種サービスを起動して使用する事が可能です。

###<a name="distributedmode"></a>distributed mode

インストールされるアプリケーションは下記の通りです。

|#|Application/Service|
|:--:|:--|
|1|ZooKeeper|
|2|Kafka|
|3|MongoDB|
|4|Storm nimbus|
|5|Storm supervisor|
|6|Storm UI|
|7|GungnirServer|

`vagrant up`後、各種サービスを起動して使用する事が可能です。
※ Storm UIは起動しなくても使用する事が可能です。



##<a name="config"></a>config.ini

`files/config.ini`に各種設定を書く事ができます。

|#|Section Name|Key|Value|default Value|
|:--:|:--|:--|:--|:--|
|1|common|mode|[local](#localmod)/[distributed](#distributedmode)|distributed|
|2|zookeeper|install|true/false|true|
|3|zookeeper|dir|-|/opt|
|4|zookeeper|version|-|3.4.5|
|5|zookeeper|user|-|vagrant|
|6|zookeeper|group|-|vagrant|
|7|zookeeper|service|on/off|off|
|8|kafka|install|true/false|true|
|9|kafka|version|-|0.8.0|
|10|kafka|scala|-|2.8.0|
|11|kafka|user|-|vagrant|
|12|kafka|group|-|vagrant|
|13|kafka|service|on/off|off|
|14|mongodb|install|true/false|true|
|15|mongodb|service|on/off|off|
|16|storm|install|true/false|true|
|17|storm|dir|-|/opt|
|18|storm|version|-|0.9.0.1|
|19|storm|user|-|vagrant|
|20|storm|group|-|vagrant|
|21|storm|service|on/off|off|
|22|gungnir|install|true/false|true|
|23|gungnir|dir|-|/opt|
|24|gungnir|user|-|vagrant|
|25|gungnir|group|-|vagrant|
|26|gungnir|service|on/off|off|



##<a name='service'></a> サービス

下記はサービス化しています。

|#|Service|[local](#localmode)|[distributed](#distributedmode)|備考|
|:--:|:--|:--:|:--:|:--|
|1|ZooKeeper|○|○||
|2|Kafka|○|○||
|3|MongoDB|○|○||
|4|Storm nimbus|-|○|※1 ※2|
|5|Storm supervisor|-|○|※1 ※2|
|6|Storm UI|-|-|※1 ※2|
|7|GungnirServer|○|○||

※1: localモードの場合はインストールされません。
※2: localモードかつStormをインストールしたい場合には、config.iniに`install=true`をstormセクションに明示的に記載してください。

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
|6|GungnirServer|実メモリの1/4|実メモリの1/64|
|7|GungnirClient|実メモリの1/4|実メモリの1/64|

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
