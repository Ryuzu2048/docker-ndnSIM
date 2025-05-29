FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

ARG PASSWORD

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

RUN apt-get install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo "root:${PASSWORD}" | chpasswd
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
RUN sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config

# Core dependencies
## C, C++, pkg-config, make, gcc, g++, libbz2-dev
RUN apt-get -y install \
    gcc \
    g++ \
    make \
    pkg-config \
    libbz2-dev

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

# other packages
RUN apt-get -y install \
    ccache \
    libgtk-3-dev \
    libhdf5-dev \
    doxygen \
    python3-sphinx \
    valgrind

# https://ndnsim.net/current/parallel-simulations.html
## parallel execution
RUN apt-get -y install \
    openmpi-bin \
    openmpi-common \
    openmpi-doc \
    libopenmpi-dev
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

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]