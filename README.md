![画像](http://pages.genn.ai/img/gennai.png "Image")

## Overview

genn.ai(源内)は、ストリーム処理を簡単に利用できるようにするフレームワークです。
[Hive](https://hive.apache.org/)が、[Hadoop](http://hadoop.apache.org/)を使ったデータ処理をより手軽にしているように、[Apache Storm](https://storm.apache.org/) を使ったストリーム処理を手軽に、特別なプログラミングを行うことなく試し、必要に応じてスケールしてゆける仕組みです。

溜めたデータを処理するバッチ型でのデータ処理とは異なり、現在流れているデータを今まさに手に汲み取るようにして確認、理解、分析、他のシステムとの連携、が行える仕組みとなることを目指しています。

## Structure

[Apache Storm](https://storm.apache.org/) は、ストリームとしてデータを吸い込む部分からプログラミングが必要ですが、genn.aiでは設定後、すぐにREST(JSON)の形で受け取れるようRESTサーバの機能を提供します。
そして、そこで受け取ったデータを(Storm上のトポロジとして)どう処理するかは簡単な独自のクエリ言語で記述することが可能です。

RESTサーバで受け取るデータの形や、そこに対する処理のクエリ、などを設定するには多くのデータベースと同様、コマンドラインツール(gungnir)を準備しています。
そして、さらにその処理を(Storm上に)有効化する、取り外す、といった必要な操作一式についても、このツールを用いることで簡単に行うことが可能です。

## Documentation

[ドキュメントサイト](http://pages.genn.ai/index_ja.html) にて、同コマンドラインツールの使い方や、クエリの書き方などをご確認頂くことが可能です。
現在、リクルート社内での利用に伴い改訂がかかっているため情報が追いついていない可能性があります。
随時更新していきますが、ずれがある場合はご容赦下さい。
(また、同時にご連絡頂けると幸いです)

## Getting started

ここでは、genn.aiをお試し頂くために
[公開しているvagrant環境](https://github.com/siniida/gennai.vagrant)
を利用する方法をご説明します。

### 目次

1. [アプリケーション](#application)
2. [モード(mode)](#mode)
3. [config.yaml](#config)
4. [サービス](#service)
5. [VMに関して](#vm)
6. [メモリ](#memory)
7. [サンプル](#sample)

####<a name="application"></a>アプリケーション

このvagrantにてVMにインストールされるアプリケーションは下記の通りです。

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



####<a name="mode"></a>モードの設定

下記3つのモードを設定する事ができます。
モードの変更は[config.yaml](#config)を編集することで行います。
モードによって利用されるアプリケーションが異なります。

* [minimum](#minimummode)
* [local](#localmode)
* [distributed](#distributedmode)　/* デフォルト */

※ 現状では`vagrant up`後にmodeを変更しないでください。
※ Storm UI、Storm Logviewerはデフォルトでは起動しません。必要に応じて起動して下さい。


#####<a name="minimummode"></a>minimum mode

極簡易な動作確認等に用いるモードです。最低限の機能のみインストール・設定されます。

`vagrant up`後、各種サービスを起動し、genn.aiを使用する事が可能です。

※ GungnirServerはInMemoryMetStoreで起動されます。従ってGungnirServerを停止するとメタ情報は削除されます。
※ MongoDBはインストールされないので、EMIT句でmongo_persistを用いる事はできません。
※ Kafkaに同梱されているZooKeeperを利用します。

#####<a name="localmode"></a>local mode

簡易な動作確認等に用いるモードです。
Stormを起動せずGungnirServerをローカルモードで利用します。
その為、分散処理は確認できませんが、genn.aiについて一通りの機能を試す事ができます。

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはMongoDbMetaStoreを利用します。従って、GungnirServerを再起動してもメタ情報は保持されます。

#####<a name="distributedmode"></a>distributed mode

本番環境と同等の機能を確認する事ができるモードです。
このモードを使う場合、CPU・割当メモリをデフォルト設定値を増強しておくのが望ましいです。([参照](#vm))

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはMongoDbMetaStoreを利用します。従って、GungnirServerを再起動してもめた情報は保持されます。

####<a name='service'></a> サービス

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


※1: Kafkaに同梱されているZooKeeperを利用します。
※2: GungnirServerはInMemoryMetaStoreを用いる為、MongoDBをインストールしません。
※3: distributedモードの場合のみインストールされます。
※4: `sudo service storm-ui start`で起動してください。config.yamlでservice=trueとしてもUIは起動対象外です。
※5: `sudo service storm-logviewer start`で起動してください。config.yamlでservice=trueとしてもLogViewerは対象外です。
※6: Storm UIは、同vagrantの場合は[http://192.168.30.10:8080/](http://192.168.30.10:8080/)に上がります。



####<a name="config"></a>config.yaml

`config.yaml`に各種設定を書く事ができます。

|Propertyless|Value|default Value|
|:--|:--|:--|:--|
|common.mode|[minimum](#minimummode)｜[local](#localmod)｜[distributed](#distributedmode)|distributed|
|common.hostname|[STRING]/off|off|
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



####<a name='vm'></a> VMの設定

現時点ではVM自体のメモリは各種フォルト設定で起動されているため、
重い処理を実行するとメモリが足りなくなる恐れがあります。

必要に応じてVagrantfileを編集し、VMのメモリ容量・CPU数を起動するホストマシンの性能によって調整してください。

```
  virtualbox.memory=2048
  virtualbox.cpus = 2
```



####<a name='memory'></a> アプリケーションのメモリ設定

メモリの設定を行います。

※ 実メモリの1/4, 実メモリの1/64はJDKのデフォルト設定です。

##### Default設定

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


####<a name="sample"></a> genn.aiのサンプルデータ・クエリ

[config.yaml](#config)にて下記の記述をするとサンプルをVMに配置し、実行する事ができます。

```
[common]
sample=yes
```

サンプルはホームディレクトリにsampleディレクトリを作成し、いくつかのqueryを配置します。
また、genn.aiはユーザ管理機能を提供していますが、これは事前に作成されています。
このため、VM起動後は即下記コマンドを実行する事が可能です。

```
$ /opt/gungnir-client/bin/gungnir -u gennai -p gennai
```

ここから、スキーマの設定、トポロジの入力と投入、テストデータの投入、と見てゆきます。

##### スキーマの設定

ホーム以下sample内にある下記".q"ファイルを参考に、genn.aiに待ち受けさせるスキーマ(RequestPacketとResponsePacket)を作成します。
これが、genn.aiが受け取るストリームデータのJSON書式となります。

```
sample/PacketCapture/tuple/*
```

##### トポロジの設定と投入

ホーム以下sample内にある下記".q"ファイルを参考に、受け取ったストリームデータに対しての処理をgungnirから入力します。
これがStormに対してトポロジとして登録されます。

```
sample/PacketCapture/topology.q
```

次に、同gungnirからクエリを入力します。

```
SET topology.metrics.enabled = true
;
SET topology.metrics.interval.secs = 60
;
SET default.parallelism = 32
;
FROM (
  RequestPacket JOIN ResponsePacket
  ON RequestPacket.request_pheader.Destination_Port = ResponsePacket.response_pheader.Source_Port
  AND RequestPacket.request_pheader.Source_Port = ResponsePacket.response_pheader.Destination_Port
  AND RequestPacket.request_pheader.Destination_Ip = ResponsePacket.response_pheader.Source_Ip
  AND RequestPacket.request_pheader.Source_Ip = ResponsePacket.response_pheader.Destination_Ip
  TO
    RequestPacket.request_properties AS request_properties,
    RequestPacket._time AS request_time,
    ResponsePacket.response_properties AS response_properties,
    ResponsePacket._time AS response_time
  EXPIRE 10sec
) AS packet USING kafka_spout() parallelism 8
EACH
  request_properties.Host AS host,
  request_properties.Request_URI AS uri,
  response_properties.Status AS status,
  request_time,
  response_time
INTO s1
;
FROM s1
SNAPSHOT EVERY 1min *, count() AS cnt
EACH *, sum(cnt) AS sum, ifnull(record, 'cnt_all') AS record parallelism 1
EMIT record, sum, request_time, response_time USING mongo_persist('front', 'count', ['record']) parallelism 1
;
```

この後、(トポロジへの変換＋Stormでの登録と起動)を行います。

```
gungnir> SUBMIT TOPOLOGY;
OK
gungnir> DESC TOPOLOGY;
{"id":"544a6b270cf28a00f105fb7c","status":"RUNNING","owner":"gennai","createTime":"2014-10-24T15:07:19.429Z","summary":{"name":"gungnir_544a6b270cf28a00f105fb7c","status":"ACTIVE","uptimeSecs":5,"numWorkers":1,"numExecutors":43,"numTasks":43}}
gungnir>
```

最後に、データをデバッグ投入(POST)して稼働を確認してみましょう。

```
gungnier> POST RequestPacket {"request_pheader":{"ID":20,"Source_Ip":"172.20.4.64","Destination_Ip":"160.37.39.43","Source_Port":80,"Destination_Port":1920},"request_properties":{"Host":"host.004.jp","Request_URI":"/path/002 HTTP/1.1"}};
gungnier> POST ResponsePacket {"response_pheader":{"ID":21,"Source_Ip":"160.37.39.43","Destination_Ip":"172.20.4.64","Source_Port":1920,"Destination_Port":80},"response_properties":{"Status":"HTTP/1.1 304 Not Modified"}};
gungnir>
```

ここでは、Mongoまでの出力をしているだけなので、以下で確認がで行きます。

```
[vagrant@localhost ~]$ mongo
MongoDB shell version: 2.6.5
connecting to: test
> use front;
switched to db front
> show collections;
count
service
system.indexes
> db.count.find();
{ "_id" : ObjectId("544a6f88400a9b9508bac95c"), "record" : "cnt_all_time", "sum" : NumberLong(2), "request_time" : ISODate("2014-10-24T15:25:58.407Z"), "response_time" : ISODate("2014-10-24T15:25:59.432Z") }
>
```

## Getting help

現在、メーリングリスト等は準備できておりませんが、
[ドキュメントサイト](http://pages.genn.ai/) 下段にあるDisqusか、もしくはgithub上でのやり取りにて出来る限りご質問等にはお答えするようにしています。

## License

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.

## Main developper

* Ikumasa Mukai

## Project lead

* Takeshi Nakano ([@tf0054](https://github.com/tf0054))

## Committers

* Shinji Iida
* Gaute Lambertsen ([@gautela](https://github.com/gautela))

## Contributors

* Masaru Makino
* Takahiko Ito ([@takahi-i](https://github.com/takahi-i))
