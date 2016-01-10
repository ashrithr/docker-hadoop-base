FROM ashrithr/centos-base

MAINTAINER ashrithr

USER root

# Install Java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
    && rpm -ivh jdk-7u79-linux-x64.rpm \
    && rm -f jdk-7u79-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# Export Hadoop required environment variables
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

# Download & extract Hadoop. Download Hadoop native support libraries - fixes libhadoop.so.
RUN \
    curl -s 'http://www.eu.apache.org/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz' | tar -xz -C /usr/local/ && \
    cd /usr/local && \
    ln -s ./hadoop-2.7.1 hadoop && \
    chown -R root:root /usr/local/hadoop-2.7.1 && \
    chmod 755 /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mkdir /tmp/native && \
    curl -L https://github.com/sequenceiq/docker-hadoop-build/releases/download/v2.7.1/hadoop-native-64-2.7.1.tgz | tar -xz -C /tmp/native && \
    rm -rf /usr/local/hadoop/lib/native && \
    mv /tmp/native /usr/local/hadoop/lib && \
    sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

ADD core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml