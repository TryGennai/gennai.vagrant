設定例

> ここでは、Vagrantfileの各種設定例を記載します。Vagrantfileの詳細な設定方法については[公式のドキュメント](https://docs.vagrantup.com/v2/)を参照してください。また、genn.aiの各種設定項目については[genni.ai ドキュメント](http://pages.genn.ai)を参照してください。

## 目次

1. [CPUのコア数を増やす](#cpu)
2. [メモリ容量を増やす](#memory)
3. [固定IPを設定する](#staticip)

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

**変更前**

```
 10   config.vm.network :private_network, type: "dhcp"
```

**変更後**

```
 10   config.vm.network :private_network, ip: "192.168.30.10"
```

ホストOS間の通信時に固定IPを用いた方が便利な場合があります。その際に設定し使用してください。
