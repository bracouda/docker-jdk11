FROM ubuntu:20.04

# non interactive mode for installation
ENV DEBIAN_FRONTEND noninteractive

# JAVA VERSION
ARG GRAAL_VERSION=20.0.0
ARG JAVA_VERSION=11
ENV GRAALVM_PKG=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$GRAAL_VERSION/graalvm-ce-java$JAVA_VERSION-linux-amd64-$GRAAL_VERSION.tar.gz

ENV LANG=en_US.UTF-8

RUN apt-get update \
    && apt-get install -y \
        software-properties-common \
        build-essential \
        wget \
        xvfb \
        curl \
        git \
        mercurial \
        maven \
        openjdk-$JAVA_VERSION-jdk \
        ant \
        ssh-client \
        unzip \
        iputils-ping \
        python\
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/$JAVA_VERSION-openjdk-amd64

#GRAAL VM INSTALLATION
RUN set -eux \
    && curl --fail --silent --location --retry 3 ${GRAALVM_PKG} \
    | gunzip | tar -x -C /tmp/

RUN mv /tmp/graalvm-ce-java$JAVA_VERSION-$GRAAL_VERSION/ /usr/lib/jvm/

ENV GRAALVM_HOME=/usr/lib/jvm/graalvm-ce-java$JAVA_VERSION-$GRAAL_VERSION
RUN $GRAALVM_HOME/bin/gu install native-image \
                            llvm-toolchain

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

# Create dirs and users
RUN mkdir -p /opt/bebertexecutor/build \
    && sed -i '/[ -z \"PS1\" ] && return/a\\ncase $- in\n*i*) ;;\n*) return;;\nesac' /root/.bashrc \
    && useradd --create-home --shell /bin/bash --uid 1000 bebertexecutor

WORKDIR /opt/bebertexecutor/build

ENTRYPOINT /bin/bash