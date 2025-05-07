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
git clone -b origin/ubuntu20.04 https://github.com/Ryuzu2048/docker-ndnSIM.git
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

None

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