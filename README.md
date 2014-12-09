![画像](http://pages.genn.ai/img/gennai.png "Image")

## Overview

genn.ai(源内)は、ストリーム処理を簡単に利用できるようにするフレームワークです。
[Hive](https://hive.apache.org/)が、[Hadoop](http://hadoop.apache.org/)を使ったデータ処理をより手軽にしているように、[Apache Storm](https://storm.apache.org/) を使ったストリーム処理を手軽に、特別なプログラミングを行うことなく試し、必要に応じてスケールしてゆける仕組みです。

溜めたデータを処理するバッチ型でのデータ処理とは異なり、現在流れているデータを今まさに手に汲み取るようにして確認、理解、分析、他のシステムとの連携、が行える仕組みとなることを目指しています。

## Structure

[Apache Storm](https://storm.apache.org/) は、ストリームとしてデータを吸い込む部分からプログラミングが必要ですが、genn.aiでは設定後、すぐにREST(JSON)の形で受け取れるようRESTサーバの機能を提供します。
そして、そこで受け取ったデータを(Storm上のトポロジとして)どう処理するかは簡単な独自のクエリ言語で記述することが可能です。

RESTサーバで受け取るデータの形や、そこに対する処理を定義するクエリ、などを設定するために、多くのデータベースと同様のコマンドラインツール(gungnir)を準備しています。
そして、さらにそれら設定を(Storm上に)有効化する、取り外す、といった必要な操作一式もこのツールを用いることで簡単に行うことが可能です。

## Documentation

[ドキュメントサイト](http://pages.genn.ai/index_ja.html) にて、同コマンドラインツール(gungnir)の使い方や、クエリの書き方などをご確認頂くことが可能です。
現在、リクルート社内での利用に伴い改訂がかかっているため情報が追いついていない可能性があります。
随時更新していきますが、ずれがある場合はご容赦下さい。
(また、同時に[ご連絡](http://pages.genn.ai/disqus.html)頂けると幸いです)

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

※ GungnirServerはInMemoryMetaStoreで起動されます。従ってGungnirServerを停止するとメタ情報は削除されます。
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
このモードを使う場合、CPU・割当メモリのデフォルト設定値を増強しておくのが望ましいです。([参照](#vm))

`vagrant up`後、各種サービスを起動して使用する事が可能です。

※ GungnirServerはMongoDbMetaStoreを利用します。従って、GungnirServerを再起動してもメタ情報は保持されます。

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
|9|TupleStoreServer|-|-|-|sudo service tuple-store-server [start｜stop]|/opt/gungnir-server/logs/tuple-store-server.log|※3,※7,※8|


※1: Kafkaに同梱されているZooKeeperを利用します。
※2: GungnirServerはInMemoryMetaStoreを用いる為、MongoDBをインストールしません。
※3: distributedモードの場合のみインストールされます。
※4: `sudo service storm-ui start`で起動してください。config.yamlでservice=trueとしてもUIは起動対象外です。
※5: `sudo service storm-logviewer start`で起動してください。config.yamlでservice=trueとしてもLogViewerは対象外です。
※6: Storm UIは、同vagrantの場合は[http://internal-vagrant.genn.ai:8080/](http://internal-vagrant.genn.ai:8080/)に上がります。
※7: TupleStoreServerは、distributedモードの場合のみRESTサーバ機能をGungnirServerとは別プロセスで起動することが可能となります。
※8: 初期状態ではGungnirServerと同プロセスで起動される為、別プロセスで起動するには設定ファイルを変更する必要があります



####<a name="config"></a>config.yaml

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


####<a name='vm'></a> VMの設定

現時点ではVM自体のメモリは各種デフォルト設定で起動されているため、
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
|8|GungnirClient|1024M|実メモリの1/64|
|9|TupleStoreServer|1024M|実メモリの1/64|



##<a name="sample"></a>Simple example

ここでは、極力シンプルな例を用い、genn.aiを用いたストリーム処理の全容を見てゆきます。
genn.aiは外部からRESTにてデータを受け止め、Stormのトポロジでそれを処理してゆきます。

このため、全体としては、

- 受け取るデータを定義(スキーマの設定)
- そのデータをどう処理するかを定義(トポロジの入力と投入)
- テストデータの投入

という流れになります。

でははじめましょう。
genn.aiはユーザ管理機能を提供していますが、これは事前に作成されています。
このため、VM起動後は即、(genn.aiのコマンドラインツールである)gungnirコマンドを実行する事が可能です。

```
$ /opt/gungnir-client/bin/gungnir -u gennai -p gennai
```

ここから、通常必要となる作業(先に上げたスキーマの設定、トポロジの入力と投入、テストデータの投入)を順に見てゆきます。

### スキーマの設定

そのためのサンプルはホームディレクトリにsampleディレクトリに格納されています。
この内にある"tuple.q"ファイルを参考に、genn.aiに待ち受けさせるスキーマ(simple)を作成します。
この定義が、genn.aiが受け取るストリームデータのJSON書式となる、すなわち(gennn.aiが準備する)RESTサーバがこの情報を利用します。

```
[vagrant@internal-vagrant simple]$ cat tuple.q
CREATE TUPLE simple (
    Id INT,
    Content STRING
);
[vagrant@internal-vagrant simple]$
```

### トポロジの設定と投入

次に、同sample/simple内にある"query.q"ファイルを参考に、受け取ったストリームデータに対しての処理をgungnirから入力します。
ここに上げた例の処理内容は「ContentカラムのデータがAから始まる文字列の場合のみMongoDBのtestデータベース中のsimple_outputコレクションに全カラムを出力せよ」というクエリです。(おおよそお分かりかと思います)

```
[vagrant@internal-vagrant simple]$ cat query.q
FROM simple
USING kafka_spout()
FILTER Content REGEXP '^A[A-Z]*$'
EMIT * USING mongo_persist('test', 'simple_output');
[vagrant@internal-vagrant simple]$
```

では、このクエリをStormに対してトポロジとして登録しましょう。
このときトポロジの名前として **simple_t** という名前にしています。

```
gungnir> SUBMIT TOPOLOGY simple_t;
OK
Starting ... Done
{"id":"547b01de0cf218509e5b6e0d","name":"simple_t","status":"RUNNING","owner":"gennai","createTime":"2014-11-30T11:39:10.287Z","summary":{"name":"gungnir_547b01de0cf218509e5b6e0d","status":"ACTIVE","uptimeSecs":2,"numWorkers":1,"numExecutors":3,"numTasks":3}}
gungnir>
```

Done以降に返却されているJSONは、トポロジ登録時の情報であり、例えは、"id"はトポロジにふられた固有のid、また、"status"は現在のトポロジの状態(ここではRUNNINGなのでもう起動し、処理するデータを待ち受けている状態)であることが分かります。

なお、このトポロジの状態については、DESCコマンドでも調べることができます。

```
gungnir> DESC TOPOLOGY simple_t;
{"id":"547b01de0cf218509e5b6e0d","name":"simple_t","status":"STOPPED","owner":"gennai","createTime":"2014-11-30T11:39:10.287Z"}
gungnir>
```

### 動作確認

では、動作を確認するため、早速データをデバッグ投入(POST)してみましょう。
以下では2つのデータを投入しています。

```
gungnir> POST simple {"Id":4,"Content":"ABCDEF"};
POST http://localhost:7200/gungnir/v0.1/546f4f480cf2cde01845629f/simple/json
OK
gungnir> POST simple {"Id":4,"Content":"BCDEFA"};
POST http://localhost:7200/gungnir/v0.1/546f4f480cf2cde01845629f/simple/json
OK
gungnir>
```

クエリに従い、結果は最初のデータ1つだけがMongoDBに登録されているはず。
以下のとおり、そのように正しく登録されているかどうかを確認てみましょう。

```
[vagrant@internal-vagrant ~]$ mongo
MongoDB shell version: 2.6.5
connecting to: test
> db.simple_output.find();
{ "_id" : ObjectId("547b02300cf23dc96705ef62"), "Id" : 4, "Content" : "ABCDEF" }
> exit
```

では次に、[curlコマンド](http://curl.haxx.se/docs/)を用いて外部からhttpにてデータ登録を行ってみましょう。
このとき投げ込む先のURLは、先のPOSTコマンド実行時に表示されているものを用います。

```
[vagrant@internal-vagrant ~]$ curl -v -H "Content-Type: application/json" -X POST -d '{Id:6,Content:"AZYXWV"}' http://localhost:7200/gungnir/v0.1/546f4f480cf2cde01845629f/simple/json
* About to connect() to localhost port 7200 (#0)
*   Trying ::1... connected
* Connected to localhost (::1) port 7200 (#0)
> POST /gungnir/v0.1/546f4f480cf2cde01845629f/simple/json HTTP/1.1
> User-Agent: curl/7.19.7 (x86_64-redhat-linux-gnu) libcurl/7.19.7 NSS/3.13.6.0 zlib/1.2.3 libidn/1.18 libssh2/1.4.2
> Host: localhost:7200
> Accept: */*
> Content-Type: application/json
> Content-Length: 23
>
< HTTP/1.1 204 No Content
< Content-Length: 0
< Date: Sun, 30 Nov 2014 12:27:54 GMT
<
* Connection #0 to host localhost left intact
* Closing connection #0
[vagrant@internal-vagrant ~]$
```

RESTサーバからの戻りステータスが204となっており、ここからgenn.aiに正常に届いたことが分かります。

### 動作確認(負荷がけツール)

ではさらに、genn.aiに付属しているデータ投入ツールを使ってみましょう。
ツールは、bin/postという名前で格納されています。
このツールは標準入力からデータを受け取ることもできますが、ここではファイルから読み上げる-fオプションを使います。

なお、送信するファイルの中身は以下となっています。

```
[vagrant@internal-vagrant simple]$ cat data.json
{"Id":0, "Content":"ABCDEF"}
{"Id":1, "Content":"BCDEFA"}
{"Id":2, "Content":"CDEFAB"}
[vagrant@internal-vagrant simple]$
```

また、送信時には-aオプションにgenn.aiにおけるユーザIDを指定しますが、これは以下gungnir内でdescコマンドを用いることで確認が可能です。

```
gungnir> DESC USER;
{"id":"546f4f480cf2cde01845629f","name":"gennai","createTime":"2014-11-21T14:42:16.333Z"}
gungnir>
```

では、送信してみましょう。

```
[vagrant@internal-vagrant simple]$ post -a 546f4f480cf2cde01845629f -f data.json -t simple -v
POST http://localhost:7200/gungnir/v0.1/546f4f480cf2cde01845629f/simple/json
HTTP/1.1 204 No Content
Content-Length: 0
[vagrant@internal-vagrant simple]$
```

そして、このツールは-nというオプションを持っており、そこに指定した回数分、ファイルの内容を繰り返し送信させることができます。
(つまりここではdata.jsonに3行のデータが入っているため300件送信されます)

```
[vagrant@internal-vagrant simple]$ post -a 546f4f480cf2cde01845629f -n 100 -v -f data.json -t simple
POST http://localhost:7200/gungnir/v0.1/546f4f480cf2cde01845629f/simple/json
HTTP/1.1 204 No Content
Content-Length: 0
Date: Sun, 30 Nov 2014 12:04:22 GMT
HTTP/1.1 204 No Content
Content-Length: 0
Date: Sun, 30 Nov 2014 12:04:22 GMT
HTTP/1.1 204 No Content
Content-Length: 0
--省略(合計300回レスポンスである204を受け取る)--
[vagrant@internal-vagrant simple]$
```

### 処理を追加する

では、ここで更に別のトポロジを追加してみましょう。
同様にContentカラムのデータがBから始まっているものを、別のMongoDBコレクションに格納するものを作ります。

```
FROM simple
USING kafka_spout()
FILTER Content REGEXP '^B[A-Z]*$'
EMIT * USING mongo_persist('test', 'simple_output_B');
```

そして、同様に登録、postコマンドにてサンプルのデータファイルを100回投げ込みます。

```
gungnir> SUBMIT TOPOLOGY simple_t_B;
OK
Starting ... Done
{"id":"547b07b80cf218509e5b6e0e","name":"simple_t_B","status":"RUNNING","owner":"gennai","createTime":"2014-11-30T12:04:08.960Z","summary":{"name":"gungnir_547b07b80cf218509e5b6e0e","status":"ACTIVE","uptimeSecs":2,"numWorkers":1,"numExecutors":3,"numTasks":3}}
gungnir>
```

これにより、RESTサーバが受け取るデータ(先のtuple設定のとおりsimpleという名前がついている)1つに対し、2つのトポロジが登録されたことになります。

言うなれば、これまではsimpleにはsimple_tトポロジのみが紐づいていましたが、このsubmit以後は(simpleに)simple_t_Bというトポロジも紐づいた、2つのトポロジが紐づいた状態となっています。
故に、simpleにデータを受けると、同じものが2つのトポロジに流れ込み、それぞれの処理がなされることになります。

この動作を確認するため、また300個のデータを投入しましょう。

```
[vagrant@internal-vagrant simple]$ post -a 546f4f480cf2cde01845629f -n 100 -v -f data.json -t simple
POST http://localhost:7200/gungnir/v0.1/546f4f480cf2cde01845629f/simple/json
HTTP/1.1 204 No Content
Content-Length: 0
Date: Sun, 30 Nov 2014 12:04:22 GMT
HTTP/1.1 204 No Content
Content-Length: 0
Date: Sun, 30 Nov 2014 12:04:22 GMT
HTTP/1.1 204 No Content
Content-Length: 0
--省略--
[vagrant@internal-vagrant simple]$
```

このように1つのデータに対して複数の処理を紐づけられる機能は、新たな処理を追加するためのテストを容易とするなど多くの利点があります。

最後にMongoDBを確認します。
MongoDBのコレクションsimple_outputにはContentカラムのデータにおいて先頭文字がAのデータが、simple_output_Bには同様に先頭文字がBのデータが格納されることが分かります。

```
[vagrant@internal-vagrant ~]$ mongo
MongoDB shell version: 2.6.5
connecting to: test
> db.simple_output.find();
{ "_id" : ObjectId("547b07580cf23dc96705ef73"), "Id" : 0, "Content" : "ABCDEF" }
{ "_id" : ObjectId("547b07580cf23dc96705ef73"), "Id" : 0, "Content" : "ABCDEF" }
{ "_id" : ObjectId("547b07580cf23dc96705ef73"), "Id" : 0, "Content" : "ABCDEF" }
--省略--
Type "it" for more
> db.simple_output_B.find();
{ "_id" : ObjectId("547b07c60cf245af63550606"), "Id" : 1, "Content" : "BCDEFA" }
{ "_id" : ObjectId("547b07c60cf245af63550607"), "Id" : 1, "Content" : "BCDEFA" }
{ "_id" : ObjectId("547b07c60cf245af63550608"), "Id" : 1, "Content" : "BCDEFA" }
--省略--
Type "it" for more
>
```

これまでvagrantに格納されているサンプルを用いて、genn.aiのほんの一機能について確認してゆく方法をご紹介しました。
より複雑な、より高度なクエリについては、こちらのページを参考にして下さい。



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
