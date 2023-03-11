#!/bin/bash

download__hadoop () {
	## Go to Home Folder
	cd ~

	## Download the hadoop tar
	wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz

	## Extract hadoop tar 
	tar -xzf hadoop-3.3.4.tar.gz
	mv hadoop-3.3.4 hadoop

	## Export environmental variables.
	echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc
	echo 'export HADOOP_INSTALL=/home/user/hadoop' >> ~/.bashrc
	echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> ~/.bashrc
	echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> ~/.bashrc
	echo 'export HADOOP_HOME=$HADOOP_INSTALL' >> ~/.bashrc
	echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> ~/.bashrc
	echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> ~/.bashrc
	echo 'export HADOOP_CONF_DIR=$HADOOP_INSTALL/etc/hadoop' >> ~/.bashrc
	echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> ~/.bashrc
	echo 'export YARN_HOME=$HADOOP_INSTALL' >> ~/.bashrc

	source ~/.bashrc
}

configure_hadoop () {
	## Edit core-site.xml to set hdfs default path to hdfs://master:9000
	CORE_SITE_CONTENT="\t<property>\n\t\t<name>fs.defaultFS</name>\n\t\t<value>hdfs://master:9000</value>\n\t</property>"
	INPUT_CORE_SITE_CONTENT=$(echo $CORE_SITE_CONTENT | sed 's/\//\\\//g')
	sed -i "/<\/configuration>/ s/.*/${INPUT_CORE_SITE_CONTENT}\n&/" /home/user/hadoop/etc/hadoop/core-site.xml

	## Edit hdfs-site.xml to set hadoop file system parameters
	HDFS_SITE_CONTENT="\t<property>\n\t\t<name>dfs.replication</name>\n\t\t<value>3</value>\n\t</property>"
	HDFS_SITE_CONTENT="${HDFS_SITE_CONTENT}\n\t<property>\n\t\t<name>dfs.namenode.name.dir</name>\n\t\t<value>/home/user/hdfsname</value>\n\t</property>"
	HDFS_SITE_CONTENT="${HDFS_SITE_CONTENT}\n\t<property>\n\t\t<name>dfs.datanode.data.dir</name>\n\t\t<value>/home/user/hdfsdata</value>\n\t</property>"
	INPUT_HDFS_SITE_CONTENT=$(echo $HDFS_SITE_CONTENT | sed 's/\//\\\//g')
	sed -i "/<\/configuration>/ s/.*/${INPUT_HDFS_SITE_CONTENT}\n&/" /home/user/hadoop/etc/hadoop/hdfs-site.xml

	## Set the three datanodes for the distributed filesystem
	echo "master" > /home/user/hadoop/etc/hadoop/workers
	echo "slave1" >> /home/user/hadoop/etc/hadoop/workers
	echo "slave2" >> /home/user/hadoop/etc/hadoop/workers

	## Export JAVA_HOME variable for hadoop
	sed -i '/export JAVA\_HOME/c\export JAVA\_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64' /home/user/hadoop/etc/hadoop/hadoop-env.sh
}

echo "STARTING DOWNLOAD ON MASTER"
download__hadoop

echo "STARTING DOWNLOAD ON SLAVE1"
ssh user@slave1 "$(typeset -f download__hadoop); download__hadoop"

echo "STARTING DOWNLOAD ON SLAVE2"
ssh user@slave2 "$(typeset -f download__hadoop); download__hadoop"

echo "STARTING HADOOP CONFIGURE ON MASTER"
source ~/.bashrc; configure_hadoop

echo "STARTING HADOOP CONFIGURE ON SLAVE1"
ssh user@slave1 "$(typeset -f configure_hadoop); configure_hadoop"

echo "STARTING HADOOP CONFIGURE ON SLAVE2"
ssh user@slave2 "$(typeset -f configure_hadoop); configure_hadoop"
