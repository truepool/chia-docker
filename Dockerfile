FROM ubuntu:latest

EXPOSE 8555
EXPOSE 8444

ENV keys="generate"
ENV harvester="false"
ENV farmer="false"
ENV plots_dir="/plots"
ENV farmer_address="null"
ENV farmer_port="null"
ENV testnet="false"
ENV full_node_port="null"
ENV TZ="UTC"
ENV CHIA_BRANCH="1.7.1"
ENV CHIADOG_VERSION="v0.7.0"
ENV FARMR_VERSION="v1.7.7.4"

# Chia
RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl jq python3 ansible tar bash ca-certificates git openssl unzip wget python3-pip sudo acl build-essential python3-dev python3-venv python3-distutils apt nfs-common python-is-python3 vim tzdata libsodium-dev libnuma-dev rsync tmux mc sqlite3 libgmp-dev

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN echo "cloning ${CHIA_BRANCH}"
RUN git clone --branch ${CHIA_BRANCH} https://github.com/Chia-Network/chia-blockchain.git \
&& cd chia-blockchain \
&& git submodule update --init mozilla-ca \
&& chmod +x install.sh \
&& /usr/bin/sh ./install.sh

# Farmr
RUN wget https://github.com/joaquimguimaraes/farmr/releases/download/${FARMR_VERSION}/farmr-linux-x86_64.tar.gz \
&& mkdir /farmr \
&& tar xf farmr-linux-x86_64.tar.gz -C /farmr/ \
&& rm farmr-linux-x86_64.tar.gz

# Chiadog
RUN wget https://github.com/martomi/chiadog/archive/refs/tags/${CHIADOG_VERSION}.tar.gz \
&& tar xf ${CHIADOG_VERSION}.tar.gz \
&& rm ${CHIADOG_VERSION}.tar.gz \
&& mv chiadog-*/ /chiadog \
&& cd /chiadog && ./install.sh

# Setup Chia
ENV PATH=/chia-blockchain/venv/bin/:$PATH
WORKDIR /chia-blockchain
ADD ./entrypoint.sh entrypoint.sh

# Setup custom bashrc
COPY ./files/bashrc /root/.bashrc

ENTRYPOINT ["bash", "./entrypoint.sh"]
