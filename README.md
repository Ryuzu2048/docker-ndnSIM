# docker-ndnSIM

## 概要

- ndnSIMのDockerイメージを作成するためのリポジトリです。
- 基本的に、[Getting Started &#8212;  ndnSIM documentation](https://ndnsim.net/current/getting-started.html)の手順に従って、[`Dockerfile`](./Dockerfile)及び[`entrypoint.sh`](./entrypoint.sh)を作成しています。
- Dev Container対応

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

### リポジトリのクローン

```shell
git clone -b origin/ubuntu24.04 https://github.com/Ryuzu2048/docker-ndnSIM.git
```

### 起動

```shell
docker compose up
```

※1 `-d`オプションを付けると、バックグラウンドで起動します。
※2 初回が、イメージのビルドに時間がかかります。

### 停止

```shell
docker compose down
```

### コンテナに入る

```shell
docker compose exec ndnsim-docker /bin/bash
```

### コンテナ情報の確認（抜粋ver）

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

#### `work/ndnSIM/ns-3/build/src/antenna/bindings/ns3module.cc`

```diff
- Py_TYPE(&PyNs3Angles_Type) = &PyNs3AnglesMeta_Type;
+ Py_SET_TYPE(&PyNs3Angles_Type, &PyNs3AnglesMeta_Type);
```

#### `work/ndnSIM/ns-3/build/src/aodv/bindings/ns3module.cc`

```diff
- Py_TYPE(&PyNs3AodvRoutingProtocol_Type) = &PyNs3AodvRoutingProtocolMeta_Type;
+ Py_SET_TYPE(&PyNs3AodvRoutingProtocol_Type, &PyNs3AodvRoutingProtocolMeta_Type);
```

#### `work/ndnSIM/ns-3/build/src/core/bindings/ns3module.cc`

```diff
- Py_TYPE(&PyNs3Length_Type) = &PyNs3LengthMeta_Type;
+ Py_SET_TYPE(&PyNs3Length_Type, &PyNs3LengthMeta_Type);
```

```diff
- Py_TYPE(&PyNs3Int64x64_t_Type) = &PyNs3Int64x64_tMeta_Type;
+Py_SET_TYPE(&PyNs3Int64x64_t_Type, &PyNs3Int64x64_tMeta_Type);
```

```diff
- Py_TYPE(&PyNs3WallClockSynchronizer_Type) = &PyNs3WallClockSynchronizerMeta_Type;
+ Py_SET_TYPE(&PyNs3WallClockSynchronizer_Type, &PyNs3WallClockSynchronizerMeta_Type);
```

```diff
- Py_TYPE(&PyNs3NormalRandomVariable_Type) = &PyNs3NormalRandomVariableMeta_Type;
+ Py_SET_TYPE(&PyNs3NormalRandomVariable_Type, &PyNs3NormalRandomVariableMeta_Type);
```

#### `work/ndnSIM/ns-3/build/src/dsdv/bindings/ns3module.cc`

```diff
- Py_TYPE(&PyNs3DsdvRoutingProtocol_Type) = &PyNs3DsdvRoutingProtocolMeta_Type;
+ Py_SetType(&PyNs3DsdvRoutingProtocol_Type, &PyNs3DsdvRoutingProtocolMeta_Type);
```

#### `work/ndnSIM/ns-3/build/src/dsr/bindings/ns3module.cc`

```diff
- Py_TYPE(&PyNs3DsrDsrRouting_Type) = &PyNs3DsrDsrRoutingMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrRouting_Type, &PyNs3DsrDsrRoutingMeta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionAck_Type) = &PyNs3DsrDsrOptionAckMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionAck_Type, &PyNs3DsrDsrOptionAckMeta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionAckReq_Type) = &PyNs3DsrDsrOptionAckReqMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionAckReq_Type, &PyNs3DsrDsrOptionAckReqMeta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionPad1_Type) = &PyNs3DsrDsrOptionPad1Meta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionPad1_Type, &PyNs3DsrDsrOptionPad1Meta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionPadn_Type) = &PyNs3DsrDsrOptionPadnMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionPadn_Type, &PyNs3DsrDsrOptionPadnMeta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionRerr_Type) = &PyNs3DsrDsrOptionRerrMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionRerr_Type, &PyNs3DsrDsrOptionRerrMeta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionRrep_Type) = &PyNs3DsrDsrOptionRrepMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionRrep_Type, &PyNs3DsrDsrOptionRrepMeta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionRreq_Type) = &PyNs3DsrDsrOptionRreqMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionRreq_Type, &PyNs3DsrDsrOptionRreqMeta_Type);
```

```diff
- Py_TYPE(&PyNs3DsrDsrOptionSR_Type) = &PyNs3DsrDsrOptionSRMeta_Type;
+ Py_SET_TYPE(&PyNs3DsrDsrOptionSR_Type, &PyNs3DsrDsrOptionSRMeta_Type);
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