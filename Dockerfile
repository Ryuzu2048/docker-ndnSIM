FROM ubuntu:20.04

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y autoremove

RUN mkdir /work

RUN chmod -R 777 /work

WORKDIR /work

RUN apt-get -y install \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    curl \
    wget \
    gnupg2 \
    ca-certificates \
    lsb-release \
    ubuntu-keyring \
    nano \
    vim \
    traceroute \
    procps \
    htop \
    iputils-ping \
    net-tools \
    dnsutils \
    p7zip-full

# Core dependencies
## C, C++, pkg-config, make, gcc, g++, libbz2-dev
RUN apt-get -y install \
    gcc \
    g++ \
    make \
    pkg-config \
    libbz2-dev \
    pipx \
    ccache

## https://www.boost.org/users/download/
### バージョン1.88.0
# RUN wget https://archives.boost.io/release/1.88.0/source/boost_1_88_0.tar.gz && \
#     tar zxf boost_1_88_0.tar.gz && \
#     cd boost_1_88_0 && \
#     ./bootstrap.sh && \
#     ./b2 --prefix=/usr/local install && \
#     rm -rf boost_1_88_0.tar.gz && \
#     cd /work

### バージョン1.62.0
# RUN wget http://downloads.sourceforge.net/project/boost/boost/1.62.0/boost_1_62_0.tar.bz2 && \
#     tar jxf boost_1_62_0.tar.bz2 && \
#     cd boost_1_62_0 && \
#     ./bootstrap.sh && \
#     sudo ./b2 --prefix=/usr/local install && \
#     rm -rf boost_1_62_0.tar.bz2 && \
#     cd /work

### バージョン1.65.1
# RUN wget https://archives.boost.io/release/1.65.1/source/boost_1_65_1.tar.gz && \
#     tar zxf boost_1_65_1.tar.gz && \
#     cd boost_1_65_1 && \
#     ./bootstrap.sh && \
#     ./b2 --prefix=/usr/local install && \
#     rm -rf boost_1_65_1.tar.gz && \
#     cd /work

########################↓ START ↓########################    
# https://ndnsim.net/current/getting-started.html
## ndn-cxx prerequisites
RUN apt-get -y install \
    build-essential \
    libsqlite3-dev \
    libboost-all-dev \
    libssl-dev \
    git \
    python3-setuptools \
    castxml

## Dependencies for NS-3 Python bindings
RUN apt-get -y install \
    gir1.2-goocanvas-2.0 \
    gir1.2-gtk-3.0 \
    libgirepository1.0-dev \
    python3-dev \
    python3-gi \
    python3-gi-cairo \
    python3-pip \
    python3-pygraphviz \
    python3-pygccxml
    
RUN pip3 install kiwi
########################↑ END ↑########################

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'alias dir="dir --color=auto"' >> /root/.bashrc && \
    echo 'alias vdir="vdir --color=auto"' >> /root/.bashrc && \
    echo 'alias grep="grep --color=auto"' >> /root/.bashrc && \
    echo 'alias fgrep="fgrep --color=auto"' >> /root/.bashrc && \
    echo 'alias egrep="egrep --color=auto"' >> /root/.bashrc && \
    echo 'alias ls="ls --color=auto"' >> /root/.bashrc && \
    echo 'alias ll="ls -alF --color=auto"' >> /root/.bashrc && \
    echo 'alias la="ls -A --color=auto"' >> /root/.bashrc && \
    echo 'alias l="ls -CF --color=auto"' >> /root/.bashrc

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]