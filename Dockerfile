# FROM wurstmeister/base
FROM  arm32v7/openjdk:8u212-jre-slim

# do the wurstmeister/base stuff
#FROM ubuntu:trusty
#MAINTAINER Wurstmeister 
#RUN apt-get update; apt-get install -y unzip openjdk-7-jre-headless wget supervisor docker.io openssh-server
#ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/
#RUN echo 'root:wurstmeister' | chpasswd
#RUN mkdir /var/run/sshd
#RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#EXPOSE 22
# end wurstmeister/base

ARG zookeeper_version=3.4.14
ARG vcs_ref=unspecified
ARG build_date=unspecified

LABEL org.label-schema.name="zookeeper" \
      org.label-schema.description="Apache zookeeper" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/bqstony/zookeeper-docker" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      org.label-schema.version="${zookeeper_version}" \
      org.label-schema.schema-version="1.0" \
      maintainer="Wurstmeister, bqstony"

ENV ZOOKEEPER_VERSION=$zookeeper_version

# Udpate requireded package
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y wget \
 && apt-get install -y gpg

#Download Zookeeper
RUN wget -q http://mirror.vorboss.net/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz && \
wget -q https://www.apache.org/dist/zookeeper/KEYS && \
wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz.asc && \
wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz.md5

#Verify download
RUN md5sum -c zookeeper-${ZOOKEEPER_VERSION}.tar.gz.md5 && \
gpg --import KEYS && \
gpg --verify zookeeper-${ZOOKEEPER_VERSION}.tar.gz.asc

#Install
RUN tar -xzf zookeeper-${ZOOKEEPER_VERSION}.tar.gz -C /opt

#Configure
RUN mv /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo_sample.cfg /opt/zookeeper-${ZOOKEEPER_VERSION}/conf/zoo.cfg

# should be in base image and not nessessary anymore
#ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV ZK_HOME /opt/zookeeper-${ZOOKEEPER_VERSION}
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh 
EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper-${ZOOKEEPER_VERSION}
VOLUME ["/opt/zookeeper-${ZOOKEEPER_VERSION}/conf", "/opt/zookeeper-${ZOOKEEPER_VERSION}/data"]

CMD /usr/sbin/sshd && bash /usr/bin/start-zk.sh
