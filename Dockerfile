FROM ubuntu:latest AS mm_compiler
ENV MM_BRANCH="master"
ENV MM_CHECKOUT="2ffe7a6e84370d1a54e558deb392bdca9dfd89cb"
ENV BB_VERSION="v1.2.4"

WORKDIR /root

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y gcc g++ cmake libsodium-dev git libnuma-dev libgmp-dev wget

RUN echo "cloning MadMax branch ${MM_BRANCH}"
RUN git clone --branch ${MM_BRANCH} https://github.com/Chia-Network/chia-plotter-madmax \
&& cd chia-plotter-madmax \
&& git checkout ${MM_CHECKOUT} \
&& git submodule update --init \
&& /bin/sh ./make_devel.sh

RUN echo "Building BladeBit ${BB_VERSION}"
RUN wget https://github.com/Chia-Network/bladebit/archive/refs/tags/${BB_VERSION}.tar.gz \
&& tar xf ${BB_VERSION}.tar.gz \
&& rm ${BB_VERSION}.tar.gz \
&& mv bladebit-* bladebit \
&& cd bladebit \
&& mkdir -p build && cd build \
&& cmake .. && cmake --build . --target bladebit --config Release


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
ENV CHIA_BRANCH="1.3.3"
ENV CHIADOG_VERSION="v0.7.0"
ENV FARMR_VERSION="v1.7.7.4"
ENV PLOTMAN_VERSION="v0.5.1"
ENV PLOTNG_VERSION="v0.26"

# Chia
RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl jq python3 ansible tar bash ca-certificates git openssl unzip wget python3-pip sudo acl build-essential python3-dev python3.8-venv python3.8-distutils apt nfs-common python-is-python3 vim tzdata libsodium-dev libnuma-dev rsync tmux mc sqlite3 libgmp-dev

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

# Plotng
RUN wget https://github.com/maded2/plotng/releases/download/${PLOTNG_VERSION}/plotng_linux_amd64.tar.gz \
&& mkdir /plotng \
&& tar xf plotng_linux_amd64.tar.gz -C /plotng/ \
&& rm plotng_linux_amd64.tar.gz \
&& mv /plotng/plotng-client /usr/bin/plotng-client \
&& mv /plotng/plotng-server /usr/bin/plotng-server

# Plotman
RUN pip install --force-reinstall git+https://github.com/ericaltendorf/plotman@${PLOTMAN_VERSION}

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

# Copy madmax
COPY --from=mm_compiler /root/chia-plotter-madmax/build /usr/lib/chia-plotter
RUN ln -s /usr/lib/chia-plotter/chia_plot /usr/bin/chia_plot

# Copy bladebit
COPY --from=mm_compiler /root/bladebit/build/bladebit /usr/bin/bladebit

# Setup custom bashrc
COPY ./files/bashrc /root/.bashrc

ENTRYPOINT ["bash", "./entrypoint.sh"]
