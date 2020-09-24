cd ~
mv ~/sas_viya_playbook ~/sas_viya_playbook.old
cd ~
curl -o ~/SAS_Viya_playbook_VAMMACCHadoop.tgz --insecure https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/SAS_Viya_playbook_VAMMACCHadoop.tgz
tar xvf SAS_Viya_playbook_VAMMACCHadoop.tgz

# give a better name to the new inventory to be used.
cd ~/sas_viya_playbook
cp inventory.ini va_mm_acchadoop01.ini
cp -Rp ~/sas_viya_playbook.old/viya-ark ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=/etc/ssh/sshd_config regexp='X11UseLocalhost' line='X11UseLocalhost no'" -b

ansible localhost -m service -a "name=sshd state=restarted" -b
cat > ~/sas_viya_playbook/va_mm_acchadoop01.ini << EOF
sasviya01 ansible_host=intviya01.race.sas.com
sasviya02 ansible_host=intviya02.race.sas.com
sasviya03 ansible_host=intviya03.race.sas.com
sascas01 ansible_host=intcas01.race.sas.com
sascas02 ansible_host=intcas02.race.sas.com
sascas03 ansible_host=intcas03.race.sas.com

[AdminServices]
sasviya01
sasviya02
sasviya03

[CASServices]
sasviya01
sasviya02
sasviya03

[CognitiveComputingServices]
sasviya01
sasviya02
sasviya03

[CommandLine]
sasviya01
sasviya02
sasviya03
sascas01
sascas02
sascas03

[ComputeServer]
sasviya01
sasviya02
sasviya03

[ComputeServices]
sasviya01
sasviya02
sasviya03

[CoreServices]
sasviya01
sasviya02
sasviya03

[DataServices]
sasviya01
sasviya02
sasviya03

[GraphBuilderServices]
sasviya01
sasviya02
sasviya03

[HomeServices]
sasviya01
sasviya02
sasviya03

# The MicroAnalyticService host group provides a multi-threaded, low latency program execution service to support execution of decisions, business rules and scoring models.
[MicroAnalyticService]
sasviya01
sasviya02
sasviya03

# The ModelManager host group contains services to assist with organizing, managing and monitoring the contents and lifecycle of statistical and analytical models.
[ModelManager]
sasviya01
sasviya02
sasviya03

# The ModelServices host group supports registering and organizing models in a common model repository, and publishing models to different destinations.
# The microservices within this group can be integrated with other systems using the REST API.
[ModelServices]
sasviya01
sasviya02
sasviya03

[Operations]
sasviya01

[ReportServices]
sasviya01
sasviya02
sasviya03

[ReportViewerServices]
sasviya01
sasviya02
sasviya03

# The ScoringServices host group supports definition and execution of scoring jobs for models and other SAS content.
[ScoringServices]
sasviya01
sasviya02
sasviya03

[StudioViya]
sasviya01
sasviya02
sasviya03

[ThemeServices]
sasviya01
sasviya02
sasviya03

# The WorkflowManager host group contains services and applications to assist with creating workflow definitions, and managing and reporting on in-progress and historical workflow processes.
[WorkflowManager]
sasviya01
sasviya02
sasviya03

[configuratn]
sasviya01
sasviya02
sasviya03

[consul]
sasviya01
sasviya02
sasviya03

[httpproxy]
sasviya01
sasviya02
sasviya03

[pgpoolc]
sasviya01

[programming]
sasviya01
sasviya02
sasviya03

[rabbitmq]
sasviya01
sasviya02
sasviya03

[sas_casserver_primary]
sascas01

[sas_casserver_secondary]
sascas02

[sas_casserver_worker]
sascas03

[sasdatasvrc]
sasviya01
sasviya02
sasviya03

[sas_all:children]
AdminServices
CASServices
CognitiveComputingServices
CommandLine
ComputeServer
ComputeServices
CoreServices
DataServices
GraphBuilderServices
HomeServices
MicroAnalyticService
ModelManager
ModelServices
Operations
ReportServices
ReportViewerServices
ScoringServices
StudioViya
ThemeServices
WorkflowManager
configuratn
consul
httpproxy
pgpoolc
programming
rabbitmq
sas_casserver_primary
sas_casserver_secondary
sas_casserver_worker
sasdatasvrc
EOF
cp -R ~/sas_viya_playbook.old/host_vars ~/sas_viya_playbook
cd ~/sas_viya_playbook
cp vars.yml vars.yml.orig
# start from the previous vars.yml
cp ~/sas_viya_playbook.old/vars.yml ~/sas_viya_playbook/vars.yml

#update LICENSE
ansible localhost -m lineinfile -a "dest=vars.yml regexp='LICENSE_FILENAME' line='LICENSE_FILENAME: \"SASViyaV0300_09Q5VY_Linux_x86-64.txt\"'"
ansible localhost -m lineinfile -a "dest=vars.yml regexp='LICENSE_COMPOSITE_FILENAME' line='LICENSE_COMPOSITE_FILENAME: \"SASViyaV0300_09Q5VY_70180938_Linux_x86-64.jwt\"'"
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=vars.yml regexp='REPOSITORY_WAREHOUSE' line='REPOSITORY_WAREHOUSE: \"https://gelweb.race.sas.com/mirrors/yum/released/09Q5VY/sas_repos/\"'"
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=vars.yml regexp='#CAS_SETTINGS' line='CAS_SETTINGS:'"
ansible localhost -m lineinfile -a "dest=vars.yml regexp='#FOUNDATION_CONFIGURATION' line='FOUNDATION_CONFIGURATION:'"
# clean up marker code
ansible localhost -m lineinfile -a "dest=vars.yml state='absent' line='# BEGIN ANSIBLE MANAGED BLOCK'"
ansible localhost -m lineinfile -a "dest=vars.yml state='absent' line='# END ANSIBLE MANAGED BLOCK'"

cat > /tmp/insertDataAccessBlockCAS.yml << EOF
---
- hosts: localhost
  tasks:
  - name: Insert Data Access block for CAS
    blockinfile:
      path: ~/sas_viya_playbook/vars.yml
      insertafter: 'CAS_SETTINGS:'
      block: |2
          1: JAVA_HOME=/usr/lib/jvm/jre-1.8.0
          2: LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$JAVA_HOME/lib/amd64/server
EOF
ansible-playbook /tmp/insertDataAccessBlockCAS.yml

# clean up marker code
ansible localhost -m lineinfile -a "dest=vars.yml state='absent' line='# BEGIN ANSIBLE MANAGED BLOCK'"
ansible localhost -m lineinfile -a "dest=vars.yml state='absent' line='# END ANSIBLE MANAGED BLOCK'"

cat > /tmp/insertDataAccessBlockSASF.yml << EOF
---
- hosts: localhost
  tasks:
  - name: Insert Data Access block for SAS Foundation
    blockinfile:
      path: ~/sas_viya_playbook/vars.yml
      insertafter: "FOUNDATION_CONFIGURATION:"
      block: |2
          1: JAVA_HOME=/usr/lib/jvm/jre-1.8.0
          2: LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$JAVA_HOME/lib/amd64/server
EOF
ansible-playbook /tmp/insertDataAccessBlockSASF.yml
# this quick command will make the change.
# you can use a text editor if you prefer

cd ~/sas_viya_playbook/

ansible localhost -m lineinfile -a "dest=ansible.cfg regexp='inventory' line='inventory = va_mm_acchadoop01.ini'"
cd ~/sas_viya_playbook
ansible sascas03 -m service -a "name=haproxy state=stopped" -b
time ansible-playbook site.yml; ansible sas_all -m service -a "name=sas-viya-all-services.service enabled=no" -b > ./service.disable.log
cd ~/sas_viya_playbook
ansible sascas03 -m service -a "name=haproxy state=started" -b
