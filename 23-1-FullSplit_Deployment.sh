cd ~/sas_viya_playbook
time ansible-playbook deploy-cleanup.yml
cd ~/sas_viya_playbook
#uninstall the httpd package
ansible httpproxy -m yum -a "name=httpd,mod_ssl state=absent" -b
cd ~/sas_viya_playbook
ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-stop.yml -e "enable_stray_cleanup=true"
cp -Rp ~/sas_viya_playbook ~/sas_viya_playbook.old
cd ~
curl -o ~/SAS_Viya_playbook.tgz --insecure https://gelweb.race.sas.com/mirrors/yum/released/09QJ68/SAS_Viya_playbook.tgz
cd ~

# extract the Viya playbook
tar xvf SAS_Viya_playbook.tgz

# list the content of the Viya deployment playbook
cd ~/sas_viya_playbook
ls -al

#backup vars.yml and inventory.
cp vars.yml vars.yml.orig
cp inventory.ini inventory.ini.orig
cd ~/sas_viya_playbook
chmod u+w ansible.cfg
# copy the sitedefault.yml file to pre-configure the authentication
cp ~/working/homegrown/openldap/sitedefault.yml  ~/sas_viya_playbook/roles/consul/files/
cp -R ~/working/viya-ark/ ~/sas_viya_playbook
cat << 'EOF' > ~/sas_viya_playbook/split02.ini
sasviya01 ansible_host=intviya01.race.sas.com
sasviya02 ansible_host=intviya02.race.sas.com
sasviya03 ansible_host=intviya03.race.sas.com
sascas01 ansible_host=intcas01.race.sas.com
sascas02 ansible_host=intcas02.race.sas.com
sascas03 ansible_host=intcas03.race.sas.com

# The AdminServices host group contains services used to support administrative tasks that have transient load.
[AdminServices]
sasviya01

# The AdvancedAnalytics host group contains services that provide advanced analytics features.
[AdvancedAnalytics]
sasviya03

# The CASServices host group contains services used to interact between the CAS server(s) and the mid-tier services.
[CASServices]
sasviya01

# The CognitiveComputingServices host group contains services for performing common text analytics tasks.
[CognitiveComputingServices]
sasviya01

# The CommandLine host group contains command line interfaces for remote interaction with services.
# It should include every host in the deployment.
[CommandLine]
sasviya03
sasviya01
sasviya02
sascas01
sascas02
sascas03

# The ComputeServer host group contains the Compute Server that executes SAS code on behalf of the Compute Service.
# It supports more than one host during initial deployment for both single-tenant and multi-tenant deployments.
# If multiple hosts are configured, home directories must be located on shared storage devices as configured by
# the customer. Examples of shared storage are a shared directory, CAS, or other accessible location. Failover is
# not supported. In the event of a failure, a session will be established on a different host, and the user must
# log on to re-establish state. In a multi-tenant environment, hosts are shared across all tenants. Adding additional
# hosts to this host group after the initial deployment is not currently supported for multi-tenant deployments.
[ComputeServer]
sasviya03

# The ComputeServices host group contains services for launching and accessing the SAS Compute Server.
[ComputeServices]
sasviya01

# The CoreServices host group contains base-level services providing a common feature set to mid-tier services.
# SAS Logon is part of this host group.
[CoreServices]
sasviya01

# The DataMining host group contains services that provide data mining features.
[DataMining]
sasviya03

# The DataServices host group contains services that provide data management features.
[DataServices]
sasviya01

# The GraphBuilderServices host group contains services that provide tools to create and edit custom graphs.
[GraphBuilderServices]
sasviya01

# The HomeServices host group contains services that provide SAS Home and its features.
[HomeServices]
sasviya01

# The MicroAnalyticService host group provides a multi-threaded, low latency program execution service to support execution of decisions, business rules and scoring models.
[MicroAnalyticService]
sasviya03

# The ModelManager host group contains services to assist with organizing, managing and monitoring the contents and lifecycle of statistical and analytical models.
[ModelManager]
sasviya03

# The ModelServices host group supports registering and organizing models in a common model repository, and publishing models to different destinations.
# The microservices within this group can be integrated with other systems using the REST API.
[ModelServices]
sasviya03

# The Operations host group contains services that accumulate metric, log, and notification events from RabbitMQ, then process those into CAS tables which are consumed by the SAS Environment Manager application.
# The Operations services utilize applications supplied by the programming host group, so specify a target host that
# is included in the programming host group.
# The Operations host group does not support multiple hosts at this time. Do not put more than one host in the
# Operations host group.
[Operations]
sasviya03

# The ReportServices host group contains services that provide report management features.
[ReportServices]
sasviya01

# The ReportViewerServices host group contains services that provide report viewing features.
[ReportViewerServices]
sasviya01

# The ScoringServices host group supports definition and execution of scoring jobs for models and other SAS content.
[ScoringServices]
sasviya03

# The StudioViya host group contains services that provide a SAS programming interface.
[StudioViya]
sasviya01

# The ThemeServices host group contains services that provide theme management features.
[ThemeServices]
sasviya01

# The WorkflowManager host group contains services and applications to assist with creating workflow definitions, and managing and reporting on in-progress and historical workflow processes.
[WorkflowManager]
sasviya03

# The configuratn host group contains the service that manages customizable configuration for the SAS environment.
[configuratn]
sasviya01

# The consul host group contains the Consul server.
[consul]
sasviya02

# The httpproxy host group contains HTTP Proxy Server.
[httpproxy]
sasviya02

# The pgpoolc host group contains PG Pool for High Availability PostgreSQL.
[pgpoolc]
sasviya02

# The programming host group contains SAS Foundation, SAS Studio, SAS Workspace Server, SAS/CONNECT and any SAS/ACCESS engines.
# It has the same conditions as ComputeServer.
[programming]
sasviya03

# The rabbitmq host group contains Rabbit MQ, a messaging broker.
# The deployment will take the first entry in this host list as the "primary"
# machine to initialize the cluster. After that deployment, if you adjust the
# inventory and place a different entry as the first Rabbit MQ machine, you will
# run the risk two distinct Rabbit MQ clusters running independently with no
# knowledge of each other and messages split between the two.
#
# A RabbitMQ cluster must have an odd number of machines.
[rabbitmq]
sasviya02

# The sas_casserver_primary host group contains the CAS controller node.
# The first host in the sas_casserver_primary list is used by the tenant in a single-tenant deployment or by the
# provider in a multi-tenant deployment. Only one configuration of CAS (including one primary controller and one
# secondary controller) per tenant is supported. Therefore, if you change the first host in the list, you are
# changing the primary CAS controller for a single-tenant deployment or, for multi-tenant deployments, you
# are changing the primary CAS controller for the provider. Any additional hosts in the sas_casserver_primary
# list are used in a multi-tenant environment. The configuration for those additional hosts (primary controller,
# secondary controller, or worker) are determined by the tenant-vars.yml file.
# For more information about the tenant-vars.yml file, see the SAS Viya Administration documentation.
[sas_casserver_primary]
sascas01

# The sas_casserver_secondary host group can be used to create a CAS backup controller node.
# This is an optional node that can take over for the primary CAS controller node if it fails. It is used only by
# the tenant in a single-tenant deployment or by the provider in a multi-tenant deployment. Secondary controllers
# for additional tenants are determined by the tenant-vars.yml file. To support failover for predefined libraries,
# a shared file system must be available for the primary and secondary controllers. Each CAS cluster can have only
# one CAS backup controller node.
# For more information about the shared file system, see the SAS Viya deployment documentation.
[sas_casserver_secondary]

# The sas_casserver_worker host group contains CAS worker node.
# It is used only by the tenant in a single-tenant deployment or by the provider in a multi-tenant deployment. Workers
# for additional tenants are determined by the tenant-vars.yml file.
# For more information about the tenant-vars.yml file, see the SAS Viya Administration documentation.
[sas_casserver_worker]
sascas02
sascas03

# The sasdatasvrc host group contains SAS PostgreSQL.
[sasdatasvrc]
sasviya02

# [sas_all:children] contains each host group used in your SAS deployment. Do not alter its contents.
# See your deployment guide for more details.
[sas_all:children]
AdminServices
AdvancedAnalytics
CASServices
CognitiveComputingServices
CommandLine
ComputeServer
ComputeServices
CoreServices
DataMining
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
ansible localhost -m file -a "path=~/sas_viya_playbook/host_vars state=directory"
cat > ~/sas_viya_playbook/host_vars/sasviya01.yml << EOF
---
network_conf:
  SAS_HOSTNAME: intviya01.race.sas.com
  SAS_BIND_ADDR: 192.168.1.1
  SAS_EXTERNAL_HOSTNAME: sasviya01.race.sas.com
  SAS_EXTERNAL_BIND_ADDR_IF: "eth0"
EOF

cat > ~/sas_viya_playbook/host_vars/sasviya02.yml << EOF
---
network_conf:
  SAS_HOSTNAME: intviya02.race.sas.com
  SAS_BIND_ADDR: 192.168.1.2
  SAS_EXTERNAL_HOSTNAME: sasviya02.race.sas.com
  SAS_EXTERNAL_BIND_ADDR_IF: "eth0"
EOF

cat > ~/sas_viya_playbook/host_vars/sasviya03.yml << EOF
---
network_conf:
  SAS_HOSTNAME: intviya03.race.sas.com
  SAS_BIND_ADDR: 192.168.1.3
  SAS_EXTERNAL_HOSTNAME: sasviya03.race.sas.com
  SAS_EXTERNAL_BIND_ADDR_IF: "eth0"
EOF

cat > ~/sas_viya_playbook/host_vars/sascas01.yml << EOF
---
network_conf:
  SAS_HOSTNAME: intcas01.race.sas.com
  SAS_BIND_ADDR: 192.168.2.1
  SAS_EXTERNAL_HOSTNAME: sascas01.race.sas.com
  SAS_EXTERNAL_BIND_ADDR_IF: "eth0"
EOF

cat > ~/sas_viya_playbook/host_vars/sascas02.yml << EOF
---
network_conf:
  SAS_HOSTNAME: intcas02.race.sas.com
  SAS_BIND_ADDR: 192.168.2.2
  SAS_EXTERNAL_HOSTNAME: sascas02.race.sas.com
  SAS_EXTERNAL_BIND_ADDR_IF: "eth0"
EOF

cat > ~/sas_viya_playbook/host_vars/sascas03.yml << EOF
---
network_conf:
  SAS_HOSTNAME: intcas03.race.sas.com
  SAS_BIND_ADDR: 192.168.2.3
  SAS_EXTERNAL_HOSTNAME: sascas03.race.sas.com
  SAS_EXTERNAL_BIND_ADDR_IF: "eth0"
EOF
cd ~/sas_viya_playbook/
ansible localhost -m lineinfile -a "dest=ansible.cfg regexp='inventory' line='inventory = split02.ini'" --diff
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=vars.yml regexp='REPOSITORY_WAREHOUSE' line='REPOSITORY_WAREHOUSE: \"https://gelweb.race.sas.com/mirrors/yum/released/09QJ68/sas_repos/\"'"
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=vars.yml regexp='  deployTarget' line='  sasviya02:'" --diff
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=vars.yml regexp='    #webdms.workspaceServer.hostName' line='    sas.studio.basicHost: intviya03.race.sas.com'" --diff
cd ~/sas_viya_playbook
time ansible-playbook site.yml
