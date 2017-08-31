#ubuntu xenial build
#this is a fork off codingtony and updated to impala 2.9.0
#see: https://github.com/codingtony/docker-impala
#see: http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html
#see: http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/impala_noncm_installation.html
#To test: docker run --rm -ti rooneyp1976/impala /start-bash.sh

FROM ubuntu:xenial
MAINTAINER outofbrain@gmail.com

RUN apt-get update && apt-get upgrade
RUN apt-get install wget apt-transport-https software-properties-common -y
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update -y
RUN apt-get install -y openjdk-7-jdk

RUN wget 'https://archive.cloudera.com/cdh5/ubuntu/xenial/amd64/cdh/cloudera.list' -O /etc/apt/sources.list.d/cloudera.list
RUN echo 'Package: *\n\
Pin: release o=Cloudera, l=Cloudera\n\
Pin-Priority: 501\n'\
>> /etc/apt/preferences.d/cloudera.pref
RUN wget https://archive.cloudera.com/cdh5/ubuntu/xenial/amd64/cdh/archive.key -O archive.key && apt-key add archive.key

RUN apt-get update
RUN apt-get install hadoop-hdfs-namenode hadoop-hdfs-datanode -y
RUN apt-get install impala impala-server impala-shell impala-catalog impala-state-store -y

RUN mkdir /var/run/hdfs-sockets/ ||:
RUN chown hdfs.hadoop /var/run/hdfs-sockets/

RUN mkdir -p /data/dn/
RUN chown hdfs.hadoop /data/dn

# Hadoop Configuration files
# /etc/hadoop/conf/ --> /etc/alternatives/hadoop-conf/ --> /etc/hadoop/conf/ --> /etc/hadoop/conf.empty/
# /etc/impala/conf/ --> /etc/impala/conf.dist
ADD files/core-site.xml /etc/hadoop/conf/
ADD files/hdfs-site.xml /etc/hadoop/conf/
ADD files/core-site.xml /etc/impala/conf/
ADD files/hdfs-site.xml /etc/impala/conf/

# Various helper scripts
ADD files/start.sh /
ADD files/start-hdfs.sh /
ADD files/start-impala.sh /
ADD files/start-bash.sh /
ADD files/start-daemon.sh /
ADD files/hdp /usr/bin/hdp

# HDFS PORTS :
# 9000  Name Node IPC
# 50010 Data Node Transfer
# 50020 Data Node IPC
# 50070 Name Node HTTP
# 50075 Data Node HTTP

# IMPALA PORTS :
# 21000 Impala Shell
# 21050 Impala ODBC/JDBC
# 25000 Impala Daemon HTTP
# 25010 Impala State Store HTTP
# 25020 Impala Catalog HTTP

EXPOSE 9000 50010 50020 50070 50075 21000 21050 25000 25010 25020

CMD /start-daemon.sh
