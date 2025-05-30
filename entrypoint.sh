#!/bin/bash
set -e  # エラーが出たらスクリプトを終了

WORKDIR="/work"
NDNSIM_DIR="$WORKDIR/ndnSIM"

echo "Changing to work directory: $WORKDIR"
cd "$WORKDIR"

# ndnSIM ディレクトリ作成
mkdir -p "$NDNSIM_DIR"
cd "$NDNSIM_DIR"

# NS-3 のクローン
if [ ! -d "ns-3" ]; then
  echo "Cloning ns-3-dev..."
  git clone https://github.com/named-data-ndnSIM/ns-3-dev.git ns-3
else
  echo "ns-3 already exists, skipping clone."
fi

# Pybindgen のクローン
if [ ! -d "pybindgen" ]; then
  echo "Cloning pybindgen..."
  git clone https://github.com/named-data-ndnSIM/pybindgen.git pybindgen
else
  echo "pybindgen already exists, skipping clone."
fi

# Click のクローン
## https://www.nsnam.org/docs/models/html/click.html
if [ ! -d "click" ]; then
  echo "Cloning click..."
  git clone https://github.com/kohler/click.git click
  cd click
  ./configure --disable-linuxmodule --enable-nsclick --enable-wifi
  make
  cd "$NDNSIM_DIR"
else
  echo "click already exists, skipping clone."
fi

# ndnSIM とサブモジュールの取得
if [ ! -d "ns-3/src/ndnSIM" ]; then
  echo "Cloning ndnSIM with submodules..."
  git clone --recursive https://github.com/named-data-ndnSIM/ndnSIM.git ns-3/src/ndnSIM
else
  echo "ndnSIM already exists, updating submodules..."
  cd ns-3/src/ndnSIM

  # Git の安全ディレクトリ設定（Docker 用対応）
  echo "Registering safe.directory with git"
  git config --global --add safe.directory "$(pwd)"
  git config --global --add safe.directory "$(pwd)/NFD"
  git config --global --add safe.directory "$(pwd)/ndn-cxx"

  git submodule update --init
  cd "$NDNSIM_DIR"
fi

# BRITE のクローン
## https://www.nsnam.org/docs/models/html/brite.html
if [ ! -d "brite" ]; then
  echo "Cloning brite..."
  hg clone http://code.nsnam.org/BRITE
  cd BRITE
  make
  cd "$NDNSIM_DIR"
else
  echo "BRITE already exists, skipping clone."
fi

# 権限の設定
echo "Setting permissions for ndnSIM directories..."
chmod -R 777 "$WORKDIR"

echo "ndnSIM setup completed in $NDNSIM_DIR"

# SSH サーバーの起動
exec /usr/sbin/sshd -D
