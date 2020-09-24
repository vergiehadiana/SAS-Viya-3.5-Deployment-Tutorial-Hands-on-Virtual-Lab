cd ~/GELVIYADEP35-deploying-viya-3.5-on-linux/scripts/playbooks/apachehadooppoc/
cat << EOF > inventory.ini
sascas01  ansible_host=intcas01.race.sas.com
sascas02  ansible_host=intcas02.race.sas.com
sascas03  ansible_host=intcas03.race.sas.com

[hadoopNN]
sascas01

[hadoopDN]
sascas02
sascas03

[hadoopSNN]
sascas02
EOF
ansible-playbook gel.hadoopsetup.yml -i inventory.ini
cd ~/sas_viya_playbook
ansible sascas01 -m shell -a "ssh-keyscan -H intcas01.race.sas.com >> ~/.ssh/known_hosts" -b --become-user=hdfs
ansible sascas01 -m shell -a "ssh-keyscan -H intcas02.race.sas.com >> ~/.ssh/known_hosts" -b --become-user=hdfs
ansible sascas01 -m shell -a "ssh-keyscan -H intcas03.race.sas.com >> ~/.ssh/known_hosts" -b --become-user=hdfs
cd ~/sas_viya_playbook
ansible sascas01 -m shell -a "/usr/local/hadoop/bin/hdfs namenode -format -nonInteractive chdir='/home/hdfs'" -b --become-user=hdfs
cd ~/sas_viya_playbook
ansible sascas01 -m file -a "path=/etc/systemd/system/hdfs.service state=absent" -b
ansible sascas01 -m file -a "path=/etc/systemd/system/hdfs.service state=touch mode=0644" -b
cat > /tmp/insertHDFSServiceDef.yml << EOF
---
- hosts: sascas01
  tasks:
  - name: Insert hdfs service definition
    blockinfile:
      path: /etc/systemd/system/hdfs.service
      marker: ""
      block: |
        [Unit]
        Description=Hadoop DFS namenode and datanode
        After=syslog.target network.target remote-fs.target nss-lookup.target network-online.target
        Requires=network-online.target
        [Service]
        User=hdfs
        Group=hadoop
        Type=forking
        ExecStart=/usr/local/hadoop/sbin/start-dfs.sh
        ExecStop=/usr/local/hadoop/sbin/stop-dfs.sh
        WorkingDirectory=/home/hdfs/
        Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
        Environment=HADOOP_HOME=/usr/local/hadoop
        TimeoutStartSec=2min
        PIDFile=/tmp/hadoop-hdfs-namenode.pid
        [Install]
        WantedBy=multi-user.target
  - name: Remove blank lines blockinfile put in
    lineinfile:
      path: /etc/systemd/system/hdfs.service
      state: absent
      regexp: '^$'
EOF
ansible-playbook /tmp/insertHDFSServiceDef.yml -b --diff
ansible sascas01 -m shell -a "systemctl daemon-reload" -b
ansible sascas01 -m shell -a "systemctl start hdfs.service" -b
cd ~/sas_viya_playbook
ansible sascas01 -m shell -a "/usr/local/hadoop/bin/hadoop fs -mkdir /test" -b --become-user=hdfs
ansible sascas01 -m shell -a "/usr/local/hadoop/bin/hadoop fs -chmod 777 /test" -b --become-user=hdfs
cd ~/sas_viya_playbook
ansible sascas* -m lineinfile -a "path=/opt/sas/viya/config/etc/cas/default/casconfig_usermods.lua create=yes backup=yes line='env.HADOOP_NAMENODE=\'intcas01.race.sas.com\'\ncas.colocation=\'hdfs\'\nenv.HADOOP_HOME=\'/usr/local/hadoop\'' owner=sas mode=644" -b
cd ~/sas_viya_playbook
ansible sascas01 -m service -a "name=sas-viya-cascontroller-default state=restarted" -b
cd ~/sas_viya_playbook
# get the hdat plugin
ansible sascas01 -m fetch -a "src=/opt/sas/viya/home/SASFoundation/hdatplugins/sashdat-03.05.02.gz dest=/tmp/ owner=cloud-user flat=yes" -b
cd /tmp
gunzip sashdat-03.05.02.gz
tar -xvf sashdat-03.05.02

cd ~/sas_viya_playbook
#distribute plugin binaries
ansible sascas* -m copy -a "src=/tmp/HDATHome/bin/ dest=/usr/local/hadoop/bin remote_src=False mode=0755" -b --become-user=hdfs

#distribute plugin libs
ansible sascas* -m copy -a "src=/tmp/HDATHome/lib/ dest=/usr/local/hadoop/share/hadoop/common/lib remote_src=False" -b  --become-user=hdfs
ansible sascas* -m copy -a "src=/tmp/HDATHome/SAS_VERSION dest=/usr/local/hadoop/ remote_src=False" -b  --become-user=hdfs
cat > /tmp/hdfs-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
    <name>dfs.replication</name>
    <value>2</value>
    <description>Default block replication.
    The actual number of replications can be specified when the file is created.
    The default is used if replication is not specified in create time.
    </description>
</property>
<property>
<name>dfs.namenode.name.dir</name>
<value>/home/hdfs/hadoop-data/hdfs/namenode</value>
<description>Determines where on the local filesystem the DFS name node should store the name table(fsimage). If this is a comma-delimited list of directories then the name table is replicated in all of the directories, for redundancy.</description>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>/home/hdfs/hadoop-data/hdfs/datanode</value>
<description>Determines where on the local filesystem an DFS data node should store its blocks. If this is a comma-delimited list of directories, then data will be stored in all named directories, typically on different devices. Directories that do not exist are ignored.</description>
</property>
<property>
<name>dfs.namenode.secondary.http-address</name>
<value>intcas02.race.sas.com:50090</value>
</property>
<property>
    <name>dfs.namenode.plugins</name>
    <value>com.sas.cas.hadoop.NameNodeService</value>
    </property>
    <property>
    <name>dfs.datanode.plugins</name>
    <value>com.sas.cas.hadoop.DataNodeService</value>
    </property>
    <property>
    <name>com.sas.cas.service.allow.put</name>
    <value>true</value>
    </property>
    <property>
    <name>com.sas.cas.hadoop.service.namenode.port</name>
    <value>15452</value>
    </property>
    <property>
    <name>com.sas.cas.hadoop.service.datanode.port</name>
    <value>15453</value>
    </property>
    <property>
    <name> dfs.namenode.fs-limits.min-block-size</name>
    <value>0</value>
</property>
</configuration>
EOF
cd ~/sas_viya_playbook
ansible sascas* -m copy -a "src=/tmp/hdfs-site.xml dest=/usr/local/hadoop/etc/hadoop/ remote_src=False" -b  --become-user=hdfs --diff
cd ~/sas_viya_playbook
ansible sascas01 -m shell -a "/usr/local/hadoop/bin/hadoop fs -mkdir /user" -b --become-user=hdfs
ansible sascas01 -m shell -a "/usr/local/hadoop/bin/hadoop fs -mkdir /user/viyademo01" -b --become-user=hdfs
ansible sascas01 -m shell -a "/usr/local/hadoop/bin/hadoop fs -chown viyademo01:marketing /user/viyademo01" -b --become-user=hdfs
cd ~/sas_viya_playbook
ansible sascas01 -m shell -a "systemctl stop hdfs.service" -b
ansible sascas01 -m shell -a "systemctl start hdfs.service" -b
