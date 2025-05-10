# docker-ndnSIM

## 概要

- ndnSIMのDockerイメージを作成するためのリポジトリです。
- 基本的に、[Getting Started &#8212;  ndnSIM documentation](https://ndnsim.net/current/getting-started.html)の手順に従って、[`Dockerfile`](./Dockerfile)及び[`entrypoint.sh`](./entrypoint.sh)を作成しています。
- Dev Container対応
- `Python3.8.10`を使用しています。
- `Ubuntu 20.04`を使用しています。

## ファイル構造

```txt
📁repo
 ┣📁.devcontainer
 ┃ ┗📃devcontainer.json
 ┣📁work
 ┃ ┣📃docker-ndnSIM.code-workspace
 ┃ ┗📃.gitkeep
 ┣📃.gitignore
 ┣📃compose.yaml
 ┣📃Dockerfile
 ┣📃entrypoint.sh
 ┗📃Readme.md
```

- `.devcontainer` : Dev Containerの設定ファイル
- `work` : 作業ディレクトリ
- `docker-ndnSIM.code-workspace` : VSCodeのワークスペースファイル
- `.gitkeep` : 空のディレクトリをGitで管理するためのファイル
- `.gitignore` : Gitで管理しないファイルを指定するためのファイル
- `compose.yaml` : Docker Composeの設定ファイル
- `Dockerfile` : Dockerイメージの設定ファイル
- `entrypoint.sh` : コンテナ起動時に実行されるスクリプト

## 使い方

### 1. リポジトリのクローン

> [!NOTE]
> 既にリポジトリ（[Ryuzu2048/docker-ndnSIM](https://github.com/Ryuzu2048/docker-ndnSIM/)）をクローンしている場合は、`git pull`を実行してください。

```shell
git clone -b origin/ubuntu20.04 https://github.com/Ryuzu2048/docker-ndnSIM.git
```

### 2. `.env`ファイルの作成

```shell
cp .env.example .env
```

`.env`ファイルを作成し、必要な環境変数を設定します。

`.env`ファイルの例は以下の通りです。

```
PASSWORD=passwd001
SSH_PORT=10022
LOCALHOST_BINDING=127.0.0.1
```

- `PASSWORD` : SSH接続時のパスワード
  - 各自で設定してください。
- `SSH_PORT` : SSH接続時のポート番号
  - 例の場合、`10022`がbindされます。
- `LOCALHOST_BINDING` : SSH接続時のローカルホストのIPアドレス
    - `LOCALHOST_BINDING`は、空欄にすると、`0.0.0.0`が設定されます。
    - 基本的には、`127.0.0.1`を指定してください。localhost外からSSH接続する場合は、空欄にしてください。
    - [compose.yaml](./compose.yaml)の`ports`セクションで、使用する。

### 3. Docker

> [!NOTE]
> 必要に応じて[Dev Container](https://code.visualstudio.com/docs/devcontainers/containers)を使用してください。

#### 3.1 起動

```shell
docker compose up
```

- ※1 `-d`オプションを付けると、バックグラウンドで起動します。
- ※2 初回が、イメージのビルドに時間がかかります。
- ※3 `docker compose build`を実行すると、イメージのビルドが行われます。

#### 3.2 コンテナに入る

```shell
docker compose exec ndnsim-docker /bin/bash
```

#### 3.3 停止

```shell
docker compose down
```

### 4. SSH接続

> [!IMPORTANT]
> 必須ではありませんが、必要に応じてSSH接続を使用してください。

[2. `.env`ファイルの作成](#2-envファイルの作成)で設定した`SSH_PORT`を使用して、SSH接続を行います。

```shell
ssh -p <SSH_PORT> root@<host>
```

[PyViz visualizer](#pyviz-visualizer)を使用する場合、`-AXY`オプションを指定してください。
- `-A` : SSHエージェント転送を有効にします。
- `-X` : X11転送を有効にします。
- `-Y` : 信頼できるX11転送を有効にします。

```shell
ssh -p <SSH_PORT> -AXY root@<host>
```

### `waf`コマンドのPythonに関して

#### Pythonを使用する場合

```shell
# python3 -V
Python 3.8.10
```

Pythonのバージョンは、`3.8.10`を使用しています。

その為、[`PEP 674 – Disallow using macros as l-values`](https://peps.python.org/pep-0674/)は起きません。

もし、`waf`コマンドで、Pythonを指定したい場合、特にオプションは必要ありません。

```shell
./waf configure
```

#### Pythonを使用しない場合

`--disable-python`オプションを指定することで、Pythonを使用しないように設定できます。

```shell
./waf configure --disable-python
```

## PyViz visualizer

- [Simulating using ndnSIM](https://ndnsim.net/current/getting-started.html#simulating-using-ndnsim)
- [PyViz visualizer](https://www.nsnam.org/wiki/PyViz)

ndnSIMでシミュレーションを実行する際に、PyViz visualizerを使用することができます。

使用する際は、`--vis`オプションを指定してください。

> [!NOTE]
>
> 現時点での確認情報
>
> - `Dev Container`を使用している場合、`--vis`オプションを指定すると、PyViz visualizerが起動します。
> - SSH接続を使用している場合、接続時に、`-AXY`オプションを指定してください。
>   - `ssh -AXY <user>@<host>`
> - `Docker Compose`から起動する場合、環境によっては使用できない場合があります。
>   - `docker compose up`

### 例

```shell
./waf --run=ndn-simple --vis
```

## 注意点

- Boostを最新バージョンでインストールすると、不具合がたくさん出ています。
    - 最新バージョンにしろとは書かれていた。
- 固定幅整数型が未定義のため、`ns3::uint32_t`を使用することがあり、ビルドエラーが発生することがあります。なんでや
    - `#include <cstdint>`を追加することで解決します。
- Boostのバージョンによって、ビルドエラーが発生することがあります。
- [https://www.nsnam.org/wiki/HOWTO_build_old_versions_of_ns-3_on_newer_compilers](HOWTO build old versions of ns-3 on newer compilers - Nsnam)

> Waf-based builds
> 
> ns-3 with Waf builds with the following flags by default: "-Wall -Werror". This causes build warnings to trigger an error and stop the build. This causes problems when trying to build older versions of ns-3 on newer systems with newer compilers, since over time, gcc and clang get more strict.
> 
> Since ns-3.29 release, Waf included a configure option to disable the "Werror" flag; in this case, warnings will be emitted but they will not stop the build.
> 
> For ns-3.29 through ns-3.35 release, to disable warnings from breaking your build, do the following:
> 
>  ./waf configure --disable-werror ...(remainder of your configuration options, if any)
>  ./waf build

### STL header error
- [https://www.nsnam.org/wiki/HOWTO_build_old_versions_of_ns-3_on_newer_compilers](HOWTO build old versions of ns-3 on newer compilers - Nsnam)


> You may run into other issues (such as missing header files) in trying to build on newer platforms. e.g.

```
 14:16:16 runner system command -> ['/bin/g++', '-Wall', '-fPIC', '-DPIC', '-Idebug', '-I..', '-DNS3_ASSERT_ENABLE', 
 '-DNS3_LOG_ENABLE', '-DNETWORK_SIMULATION_CRADLE', '-DNS3_MODULE_COMPILATION', '../src/common/spectrum-model.cc', '-c', 
 '-o', 'debug/src/common/spectrum-model_1.o']
 In file included from ../src/common/spectrum-model.cc:22:0:
 debug/ns3/spectrum-model.h:91:3: error: ‘size_t’ does not name a type
```

> This particular error is due to a change in C++ STL; the STL headers no longer incorporate c-style headers, so one must include <cstddef> explicitly.

### header fileの追加

STLエラーや一部エラーが出ます。エラーメッセージを見て、必要なヘッダーファイルを追加してください。

以下、例

- `#include <cstdint>`
  - `work/ndnSIM/ns-3/src/network/utils/bit-serializer.h`
  - `work/ndnSIM/ns-3/src/network/utils/bit-deserializer.h`
  - `work/ndnSIM/ns-3/src/wifi/model/block-ack-type.h`

- `#include <optional>`
  - `work/ndnSIM/ns-3/src/ndnSIM/ndn-cxx/ndn-cxx/util/scheduler.hpp`

- `#include <boost/range/iterator_range.hpp>`
  - `work/ndnSIM/ns-3/src/ndnSIM/NFD/daemon/table/name-tree.hpp`

- `#include <boost/asio/io_service.hpp>`
  - `work/ndnSIM/ns-3/src/ndnSIM/NFD/daemon/face/face-system.hpp`
  - `work/ndnSIM/ns-3/src/ndnSIM/NFD/daemon/mgmt/face-manager.hpp`
  - `work.ndnSIM/ns-3/src/ndnSIM/ndn-cxx/ndn-cxx/net/network-monitor.hpp`

- `#include <boost/asio/ip/address.hpp>`
  - `work/ndnSIM/ns-3/src/ndnSIM/NFD/core/network.hpp`

### 書き換え

Boostのバージョンによって、`ip::address::from_string`が使えなくなることがあります。

その場合は、`boost::asio::ip::make_address`に書き換えてください。

#### `work/ndnSIM/ns-3/src/ndnSIM/NFD/core/network.hpp`

```diff
- network.m_minAddress = ip::address::from_string(networkStr);
+ network.m_minAddress = boost::asio::ip::make_address(networkStr);

- network.m_maxAddress = ip::address::from_string(networkStr);
+ network.m_maxAddress = boost::asio::ip::make_address(networkStr);
```

```diff
- auto address = ip::address::from_string(networkStr.substr(0, position), ec);
+ auto address = boost::asio::ip::make_address(networkStr.substr(0, position), ec);
```

## 小ネタ

### ファイルを探したい

```shell
find /work -name "<探したいファイル名>" 2>/dev/null
```

### コンテナ、イメージ、ボリューム、キャッシュの全削除

#### コンテナの全削除

```shell
docker rm $(docker ps -aq)
```

#### イメージの全削除

```shell
docker rmi $(docker images -aq)
```

### ボリュームの全削除

```shell
docker volume rm $(docker volume ls -qf dangling=true)
```

#### キャッシュの全削除

```shell
docker builder prune -a
```

#### コンテナ、イメージ、ボリューム、キャッシュの全削除

```shell
echo "【echo】docker rm $(docker ps -aq)" ; \
docker rm $(docker ps -aq) ;\
echo "【echo】docker rmi $(docker images -aq)" ;\
docker rmi $(docker images -aq) ;\
echo "【echo】docker volume rm $(docker volume ls -qf dangling=true)";\
docker volume rm $(docker volume ls -qf dangling=true);\
echo "【echo】docker builder prune -a";\
docker builder prune -a
```

### コンテナ情報の確認（抜粋ver）

- Hostname
- ContainerID
- ContainerName
- MacAddress
- Mounts
  - Source
  - Destination
- Gateway
- IPAddress(IPv4)

が確認できます。

```shell
docker inspect --format='
==========================
Hostname: {{.Config.Hostname}}
ContainerID: {{.Id}}
ContainerName: {{.Name}}
MacAddress: {{range .NetworkSettings.Networks}}{{.MacAddress}}{{end}}
Mounts:{{range .Mounts}}
  - Source: {{.Source}}
  - Destination: {{.Destination}}{{end}}
Gateway: {{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}
IPAddress(IPv4): {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}/{{range .NetworkSettings.Networks}}{{.IPPrefixLen}}{{end}}
===========================
' ndnsim-docker
```