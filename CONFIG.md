設定例

> ここでは、Vagrantfileの各種設定例と、genn.aiの一歩進んだ構成例を記載します。Vagrantfileの詳細な設定方法については[公式のドキュメント](https://docs.vagrantup.com/v2/)を参照してください。また、genn.aiの各種設定項目については[genni.ai ドキュメント](http://pages.genn.ai)を参照してください。



## 目次

1. [CPUのコア数を増やす](#cpu)
2. [メモリ容量を増やす](#memory)
3. [固定IPを設定する](#staticip)
4. [genn.ai疑似分散モードを設定](#pseudo)
5. [1台でgenn.ai分散モードを設定](#distributed)
6. [1台のホストマシン上にVagrantで複数台起動して分散](#multiservers)



##<a name='cpu'></a> CPUのコア数を増やす

CPUのコア数を増やすには、Vagrantfileの下記行を編集してください。

```
 11   config.vm.provider "virtualbox" do |virtualbox|
 12     virtualbox.memory = 2048
 13     virtualbox.cpus = 2
 14   end
```

`virtualbox.memory`の値を変更します。ホストマシンの性能に応じて適切な値を設定してください。



##<a name='memory'></a> メモリ容量を増やす

メモリ容量を増やすには、Vagrantfileの下記行を編集してください。

```
 11   config.vm.provider "virtualbox" do |virtualbox|
 12     virtualbox.memory = 2048
 13     virtualbox.cpus = 2
 14   end
```

`virtualbox.memory`の値を変更します。ホストマシンの性能に応じて適切な値を設定してください。



##<a name='staticip'></a> 固定IPを設定する

固定IPを設定するには、Vagrantfileの下記行を編集してください。

#### 変更前

```
 10   config.vm.network :private_network, type: "dhcp"
```

#### 変更後

```
 10   config.vm.network :private_network, ip: "192.168.30.10"
```

ホストOS間の通信時に固定IPを用いた方が便利な場合があります。その際に設定し使用してください。



##<a name='pseudo'></a> genn.ai疑似分散モードを設定

デフォルト設定(`common.mode: "distributed"`)では、genn.aiは下記が分散モードで稼働しています。

* ZooKeeper
* Kafka
* Storm

GungnirServerは **ローカルモード** で稼働しており、TupleStoreServerはGungnirServerと同じプロセス上で稼働しています。ここでは、GungnirServer/TupleStoreServerを **分散モード** で稼働させる設定を記載します。

### 設定ファイル

Vagrantで起動したVMにログイン後、下記の設定ファイルを編集します。

#### gungnir-server

```
/opt/gungnir-server/conf/gungnir.yaml
```

#### gungnir-client

```
/opt/gungnir-client/conf/gungnir.yaml
```

※ GungnirServer/TupleStoreServerを分散モードで稼働させる場合、gungnir-clientも分散モードを設定してください。
※ `vagrant up`前の`config.yaml`にて`gungnir.dir`を変更している場合は、随時読み替えてください。

### 変更内容

#### /opt/gungnir-server/conf/gungnir.yaml

```
 36 ### Cluster
 37 cluster.mode: "distributed"
 38 cluster.zookeeper.servers:
 39   - "localhost:2181"
```

36行目からの **Cluster** 項目を編集してください。 **cluster.mode** , **cluster.zookeeper.servers** を設定する事でGungnirServer/TupleStoreServerは分散モードで稼働します。

#### /opt/gungnir-client/conf/gungnir.yaml

```
 25 ### Cluster
 26 cluster.mode: "distributed"
 27 cluster.zookeeper.servers:
 28   - "localhost:2181"
```

25行目からの **Cluster** 項目を編集してください。
**cluster.mode**, **cluster.zookeeper.servers** を設定する事で分散モードのGungnirServer/TupleStoreServerに接続するようになります。また、 **cluster.zookeeper.servers** は **/opt/gungnir-server/conf/gungnir.yaml** と同じ設定をしてください。

### 起動

#### GungnirServerの起動

```
$ sudo service gungnir-server start
```

#### TupleStoreServerの起動

```
$ sudo service tuple-store-server start
```

### 確認

ZooKeeperのznodeを確認する事で、GungnirServer/TupleStoreServerが分散モードで稼働しているかを確認する事ができます。

```
$ zkCli.sh
[zk: localhost:2181(CONNECTED) 0] ls /gungnir/cluster/servers
[member_0000000000]
[zk: localhost:2181(CONNECTED) 1] get /gungnir/cluster/servers/member_0000000000
{"serviceEndpoint":{"host":"internal-vagrant.genn.ai","port":7100},"additionalEndpoints":{},"status":"ALIVE","shard":0}
[zk: localhost:2181(CONNECTED) 2] ls /gungnir/cluster/stores
[member_0000000000]
[zk: localhost:2181(CONNECTED) 3] get /gungnir/cluster/stores/member_0000000000
{"serviceEndpoint":{"host":"internal-vagrant.genn.ai","port":7200},"additionalEndpoints":{},"status":"ALIVE","shard":0} 
```

znode: /gungnir/cluster/servers には、genn.aiを構成するGungnirServerのクラスタ情報が保存されます。znode: /gungnir/cluster/stores には、TupleStoreServerのクラスタ情報が保存されます。

### 注意点

* デフォルト設定のVagrantfileでは、GungnirServer/TupleStoreServerを分散モードで稼働させるには十分なリソースではありません。CPUコア数・メモリ容量を増やして利用してください。



##<a name='distributed'></a> 1台でgenn.ai分散モードを設定

1台のVM上に、GungnirServer/TupleStoreServerをそれぞれ2つ起動し、genn.ai分散モードを設定します。

### 設定ファイル

1台のVM上に、GungnirServer/TupleStoreServerをそれぞれ複数プロセス稼働させるには、設定ファイルを起動するプロセス数分用意する必要があります。ここでは、既に稼働している設定ファイルをコピーして使用します。

**/opt/gungnir-server/conf/gungnir2.yaml**

```
$ cd /opt/gungnir-server/conf
$ cp gungnir.yaml gungnir2.yaml
$ vi gungnir2.yaml
```

### 変更内容

変更内容は下記の通りです。

```
 17 ### Gungnir server
 18 gungnir.server.port: 7101
 19 gungnir.server.pid.file: gungnir-server1.pid
  :
 23 ### Tuple store server
 24 tuple.store.server.port: 7201
 25 tuple.store.server.pid.file: tuple-store-server1.pid
```

* gungnir.server.port : デフォルト設定の **7100** から、使用されていない任意のポート番号(7101)に変更
* gungnir.server.pid.file : デフォルト設定(gungnir-server.pid)から変更したPIDファイル名(コメントイン)
* tuple.store.server.port : デフォルト設定の **7200** から、使用されていない任意のポート番号(7201)に変更
* tuple.store.server.pid.file : デフォルト設定(tupe-store-server.pid)から変更したPIDファイル名(コメントイン)

これらを変更した設定ファイルを複数用意することで、任意の数のGungnirServer/TupleStoreServerを1筐体上に稼働させる事が可能です。

### 起動

設定ファイルを指定して起動します。

#### GungnirServer

```
$ cd /opt/gungnir-server
$ ./bin/gungnir-server.sh start ./conf/gungnir2.yaml
```

#### TupleStoreServer

```
$ cd /opt/gungnir-server
$ ./bin/tuple-store-server.sh start ./conf/gungnir2.yaml
```

### 確認

LISTENポートやプロセスで確認する事もできますが、ここではZooKeeperのznodeでGungnirServer/TupleStoreServerが分散モードで稼働しているかを確認します。

```
$ zkCli.sh
[zk: localhost:2181(CONNECTED) 0] ls /gungnir/cluster/servers
[member_0000000001, member_0000000000]
[zk: localhost:2181(CONNECTED) 1] get /gungnir/cluster/servers/member_0000000000
{"serviceEndpoint":{"host":"internal-vagrant.genn.ai","port":7100},"additionalEndpoints":{},"status":"ALIVE","shard":0}
[zk: localhost:2181(CONNECTED) 2] get /gungnir/cluster/servers/member_0000000001
{"serviceEndpoint":{"host":"internal-vagrant.genn.ai","port":7101},"additionalEndpoints":{},"status":"ALIVE","shard":0}
[zk: localhost:2181(CONNECTED) 3]
[zk: localhost:2181(CONNECTED) 3] ls /gungnir/cluster/stores
[member_0000000001, member_0000000000]
[zk: localhost:2181(CONNECTED) 4] get /gungnir/cluster/stores/member_0000000000
{"serviceEndpoint":{"host":"internal-vagrant.genn.ai","port":7200},"additionalEndpoints":{},"status":"ALIVE","shard":0}
[zk: localhost:2181(CONNECTED) 5] get /gungnir/cluster/stores/member_0000000001
{"serviceEndpoint":{"host":"internal-vagrant.genn.ai","port":7201},"additionalEndpoints":{},"status":"ALIVE","shard":0}
```

znode: /gungnir/cluster/servers にGungnirServerクラスタを構成する新たなメンバが追加されている事が確認できます。また、znode: /gungnir/cluster/stores にはTupleStoreServerクラスタを構成するメンバが追加されている事が確認できます。

### 注意点

* デフォルト設定のVagrantfileでは、GungnirServer/TupleStoreServerを分散モードで稼働させるには十分なリソースではありません。CPUコア数・メモリ容量を増やして利用してください。


##<a name='multiservers'></a> 1台のホストマシン上にVagrantで複数台起動して分散

複数台起動することで、genn.aiの完全分散モードをホストマシン上で再現することができます。(ホストマシンのリソースを大量に消費しますので、十分な性能のホストマシン上にておこなってください。)

ここでは1台のホストマシン上に2台のゲストマシンを起動することで、genn.aiの完全分散モードを各種設定と共に試してみます。

### 構成

|Vagrant|1台目|2台目|
|:--|:-:|:-:|
|MongoDB|○|-|
|ZooKeeper|○|-|
|Kafka|○|-|
|Storm nimbus|○|-|
|Storm supervisor|○|○|
|GungnirServer|○|○|
|TupleStoreServer|○|○|

MongoDB, ZooKeeper, Kafkaを複数台でクラスタ構成を組むことも可能ですが、今回はgenn.aiを構成する主なStorm, GungnirServer, TupleStoreServerのみクラスタ構成を組むことを試します。

### 手順

1. gennai.vagrantを2ヶ所に`git clone`
2. Vagrantfileを編集
3. `vagrant up`
4. 設定ファイル編集

### 1. gennai.vagrantを2ヶ所に`git clone`

2台のVMを使用するため、server1, server2とディレクトリ名を変えて`git clone`を実行します。

```
$ cd /tmp
$ git clone https://github.com/siniida/gennai.vagrant server1
$ git clone https://github.com/siniida/gennai.vagrant server2
```

### 2. Vagrantfileを編集

元のファイルをそれぞれ下記のように編集しています。

#### server1

```
  config.vm.hostname = "server1"
```

#### server2

```
  config.vm.hostname = "server2"
```

### 3. `vagrant up`

server1, server2共に`vagrant up`で起動させます。起動させた状態ではそれぞれ個別のgenn.aiとして稼働しているので、server1は疑似分散モードに変更。server2は一度全てのサービスを停止させます。また、server1, server2共にIPを調べておきます。

ここでは、server1のIPを`172.28.128.3`、server2のIPを`172.28.128.4`として以降の設定を行います。

### 4. 設定ファイル編集

#### server1

[genn.ai疑似分散モードを設定](#pseudo)を参照にしてください。

また、MongoDBのデフォルト設定ではlocalhost以外からのアクセスが不可であるため、server2からserver1のMongoDBへのアクセスが可能になるよう設定を行います。

##### /etc/mongod.conf

    18 # Listen to local interface only. Comment out to listen on all interfaces.
    19 # bind_ip=127.0.0.1

19行目の`bind_ip`の設定をコメントアウトします。編集後、mongodを再起動します。

    $ sudo service mongod restart

#### server2

##### 各種サービスの停止

server2で不要となるサービスを全て停止します。GungnirServerもローカルモードで稼働しているので一旦停止させます。

```
$ sudo service gungnir-server stop
$ sudo service storm-supervisor stop
$ sudo service storm-nimbus stop
$ sudo service kafka stop
$ sudo service zookeeper stop
$ sudo service mongod stop
```

##### /opt/storm/conf/storm.yaml

server1のIPで指定します。

```
  2 storm.zookeeper.servers:
  3     - "172.28.128.3"
  :
  5 nimbus.host: "172.28.128.3"
```

##### /opt/gungnir-server/conf/gungnir.yaml

server1のIPで指定します。

```
 36 ### Cluster
 37 cluster.mode: "distributed"
 38 cluster.zookeeper.servers:
 39   - "172.28.128.3:2181"
  :
 49 ### Storm cluster
 50 storm.cluster.mode: "distributed"
 51 storm.nimbus.host: "172.28.128.3"
  :
 59 ### Metastore
 60 metastore: org.gennai.gungnir.metastore.MongoDbMetaStore
 61 metastore.mongodb.servers:
 62   - "172.28.128.3:27017"
  :
 64 ### Tuple store
 65 kafka.brokers:
 66   - "172.28.128.3:9092"
  :
 69 kafka.zookeeper.servers:
 70   - "172.28.128.3:2181"
  :
 98 ### Processor
  :
108 mongo.fetch.servers:
109   - "172.28.128.3:27017"
110 kafka.emit.brokers:
111   - "172.28.128.3:9092"
  :
113 mongo.persist.servers:
114   - "172.28.128.3:27017"
```

設定を完了したら、必要なサービスのみを起動します。

    $ sudo service storm-supervisor start
    $ sudo service gungnir-server start
    $ sudo service tuple-store-server start

プロセスが正常に稼働しているのを確認してください。

以降は、gungnir-client/conf/gungnir.yamlの設定が正しくされていれば、各クライアント(gungnir/post)にて複数台における完全分散モードを利用する事が可能です。