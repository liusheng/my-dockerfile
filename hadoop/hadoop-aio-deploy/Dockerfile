FROM ubuntu:bionic

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG HADOOP_DIST=hadoop-3.3.0

RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends \
       openssh-server sudo curl openjdk-8-jdk curl vim

#ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-arm64
#ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENV HADOOP_HOME /home/hadoop/${HADOOP_DIST}

RUN groupadd hadoop
RUN useradd -m -d /home/hadoop -s /bin/bash hadoop -g hadoop
RUN echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER hadoop
WORKDIR /home/hadoop
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

RUN [ "$(uname -p)" == "aarch64" ] && hadoop_tar=${HADOOP_DIST}-aarch64.tar.gz \
    || hadoop_tar=${HADOOP_DIST}.tar.gz; \
    curl -L https://downloads.apache.org/hadoop/common/${HADOOP_DIST}/${hadoop_tar} | tar zx

COPY --chown=hadoop:hadoop core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml $HADOOP_HOME/etc/hadoop/
ENV PATH "${PATH}:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"

RUN [ "$(uname -p)" == "aarch64" ] && java_home=/usr/lib/jvm/java-8-openjdk-arm64 \
    || java_home=/usr/lib/jvm/java-8-openjdk-amd64; \
    echo "export JAVA_HOME=${java_home}" >> ~/.profile; \
    echo "export JAVA_HOME=${java_home}" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

COPY --chown=hadoop:hadoop entrypoint.sh /home/hadoop/
RUN chmod +x /home/hadoop/entrypoint.sh

EXPOSE 8088 19888
ENTRYPOINT ["/home/hadoop/entrypoint.sh"]
