FROM ubuntu:trusty

LABEL org.opencontainers.image.source="https://github.com/liusheng/hadoop-2.7.7-ubuntu"
LABEL maintainer="liusheng2048@gmail.com"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

######
# Install common dependencies from packages
######
RUN apt-get update && apt-get install --no-install-recommends -y \
    git curl ant make \
    cmake gcc g++ \
    protobuf-compiler libprotoc-dev \
    protobuf-c-compiler libprotobuf-dev \
    build-essential libtool \
    zlib1g-dev pkg-config libssl-dev \
    snappy libsnappy-dev \
    bzip2 libbz2-dev \
    libjansson-dev \
    fuse libfuse-dev \
    libcurl4-openssl-dev \
    python python2.7 pylint \
    openjdk-7-jdk doxygen

#######
# Install maven 3.2.5, the maven-3.0.5 of ubuntu trusty defaultly use http than https which may cause many errors
#######
RUN curl -sL https://downloads.apache.org/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz | tar zx -C /opt/
ENV MAVEN_HOME /opt/apache-maven-3.2.5/
ENV PATH "/opt/apache-maven-3.2.5/bin:${PATH}"

#######
# Java OpenJDK
#######
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update

# Install OpenJDK 7
RUN apt-get install -y openjdk-7-jdk

######
# Install spotbugs (successor of findbugs)
######
RUN mkdir -p /opt/spotbugs && \
    curl -L -s -S \
         https://repo1.maven.org/maven2/com/github/spotbugs/spotbugs/3.1.2/spotbugs-3.1.2.tgz \
         -o /opt/spotbugs.tar.gz && \
    tar xzf /opt/spotbugs.tar.gz --strip-components 1 -C /opt/spotbugs
ENV FINDBUGS_HOME /opt/spotbugs

####
# Install shellcheck
####
RUN apt-get install -y cabal-install
RUN cabal update && cabal install shellcheck --global

###
# Avoid out of memory errors in builds
###
ENV MAVEN_OPTS -Xms256m -Xmx1536m

###
# Everything past this point is either not needed for testing or breaks Yetus.
# So tell Yetus not to read the rest of the file:
# YETUS CUT HERE
###

####
# Install Forrest (for Apache Hadoop website)
###
RUN mkdir -p /usr/local/apache-forrest ; \
    curl -O http://archive.apache.org/dist/forrest/0.8/apache-forrest-0.8.tar.gz ; \
    tar xzf *forrest* --strip-components 1 -C /usr/local/apache-forrest ; \
    echo 'forrest.home=/usr/local/apache-forrest' > build.properties

####
# Building patched protobuf-2.5.0
###
RUN curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz | tar zx -C /opt/ \
&& cd /opt/protobuf-2.5.0 \
&& curl -L -O https://gist.githubusercontent.com/liusheng/64aee1b27de037f8b9ccf1873b82c413/raw/118c2fce733a9a62a03281753572a45b6efb8639/protobuf-2.5.0-arm64.patch \
&& patch -p1 < protobuf-2.5.0-arm64.patch \
&& ./configure --prefix=/opt/protobuf \
&& make install
RUN echo "/opt/protobuf/lib/" > /etc/ld.so.conf.d/protobuf-2.5.0.conf && ldconfig
ENV PROTOBUF_HOME /opt/protobuf
ENV PATH "${PATH}:/opt/protobuf/bin"

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-arm64

RUN useradd -m -d /home/hadoop -s /bin/bash hadoop && adduser hadoop sudo
RUN echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER hadoop
WORKDIR /home/hadoop

RUN git clone https://github.com/kunpengcompute/hadoop -b release-2.7.7-aarch64

ARG prebuild=false
RUN if [ "$prebuild" = "true" ]; then \
    && cd hadoop \
    && mkdir -p ~/hadoop-results/ \
    && mvn clean install -e -B -Pdist,native -Dtar -DskipTests -Dmaven.javadoc.skip 2>&1 | sudo tee ~/hadoop-results/hadoop_build.log \
    && export PATH=${PATH}:$(readlink -f ~/hadoop/hadoop-dist/target/hadoop-2.7.7/bin); fi

COPY entrypoint.sh /opt/
RUN sudo chmod +x /opt/entrypoint.sh && sudo chown hadoop.hadoop /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]
