FROM ubuntu:19.10


RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y git \
                       zip \
                       curl \
                       build-essential \
                       libssl-dev \
                       gawk \
                       libreadline6-dev \
                       libyaml-dev \
                       libsqlite3-dev\
                       sqlite3 \
                       autoconf \
                       libgmp-dev \
                       libgdbm-dev \
                       libncurses5-dev \
                       automake \
                       libtool \
                       bison \
                       pkg-config \
                       libffi-dev \
                       automake \
                       nasm  \
                       libpng-dev\
                       libwebp-dev \
                       libmysqlclient-dev \
                       postgresql-client \
                       python \
                       python-dev \
                       python-pip \
                       python-virtualenv && \
     rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y firefox wget
# Install Chromium.

RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        google-chrome-stable

ENV CHROME_BIN /usr/bin/chrome
  
ENV NVM_DIR /usr/local/.nvm
ENV NODE_VERSION stable

# Install nvm
RUN git clone https://github.com/creationix/nvm.git $NVM_DIR && \
    cd $NVM_DIR && \
    git checkout `git describe --abbrev=0 --tags`

# Install default version of Node.js
RUN source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm install lts/boron && \
    nvm install lts/carbon && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Add nvm.sh to .bashrc for startup...
RUN echo "source ${NVM_DIR}/nvm.sh" >> $HOME/.bashrc && \
    source $HOME/.bashrc


#Need Software Properties for add apt repo
RUN apt-get install -y software-properties-common curl wget 
RUN add-apt-repository -y ppa:openjdk-r/ppa
RUN apt update && apt-get install -y openjdk-8-jdk && apt-get clean all


#Get Burp
RUN wget -q -O /opt/burpsuite.jar "https://portswigger.net/burp/releases/download?product=community&version=2.1.04&type=jar&componentid=100"

RUN echo "java -jar /opt/burpsuite.jar"> /usr/bin/burp&&chmod +x /usr/bin/burp


WORKDIR /home/workspace

RUN wget -O /opt/WebStorm.tar.gz https://download-cf.jetbrains.com/webstorm/WebStorm-2019.2.4.tar.gz --no-check-certificate

#COPY files/WebStorm-2016.1.1.tar.gz /opt/WebStorm.tar.gz

RUN tar -zxf /opt/WebStorm.tar.gz -C /opt/
RUN mv /opt/WebStorm-192.7142.35 /opt/WebStorm
RUN ln -s /opt/WebStorm/bin/webstorm.sh /usr/bin/wstorm


CMD chrome --no-sandbox&burp&wstorm
