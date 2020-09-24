    cd ~/sas_viya_playbook
    cp vars.yml DevCASSMP.vars.yml
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=DevCASSMP.vars.yml insertbefore='casenv_user:' line='casenv_instance: DevCASSMP'"
cd ~/sas_viya_playbook
cp split01.ini DevCASSMP.inventory.ini
cd ~/sas_viya_playbook
cat << 'EOF' > ~/sas_viya_playbook/DevCASSMP.inventory.ini
sasviya01 ansible_host=intviya01.race.sas.com
sasviya02 ansible_host=intviya02.race.sas.com
sasviya03 ansible_host=intviya03.race.sas.com
sascas01 ansible_host=intcas01.race.sas.com
sascas02 ansible_host=intcas02.race.sas.com
sascas03 ansible_host=intcas03.race.sas.com

[AdminServices]

[CASServices]

[CognitiveComputingServices]

[CommandLine]
sascas03

[ComputeServer]

[ComputeServices]

[CoreServices]

[DataServices]

[GraphBuilderServices]

[HomeServices]

[Operations]

[ReportServices]

[ReportViewerServices]

[StudioViya]

[ThemeServices]

[configuratn]

[consul]
sasviya02

[httpproxy]
sasviya02

[pgpoolc]

[programming]

[rabbitmq]

[sas_casserver_primary]
sascas03

[sas_casserver_secondary]

[sas_casserver_worker]

[sasdatasvrc]

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
Operations
ReportServices
ReportViewerServices
StudioViya
ThemeServices
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
cd ~/working
ansible-playbook viya-ark/playbooks/pre-install-playbook/viya_pre_install_playbook.yml \
--skip-tags skipmemfail,skipcoresfail,skipstoragefail,\
skipnicssfail,bandwidth,yum_repo \
-e 'yum_cache_yn=1' \
-e 'use_pause=no' \
-e '{"custom_group_list": { "group": "sas" , "gid":"10001" } }' \
-e '{"custom_user_list": [ { "name": "cas" , "uid":"10002", "group":"sas" , "groups":"sas" } , { "name": "sas" , "uid":"10001", "group":"sas" , "groups":"sas" } ] }'
cat > ~/sas_viya_playbook/host_vars/sascas03.yml << EOF
---
network_conf:
  SAS_HOSTNAME: intcas03.race.sas.com
  SAS_BIND_ADDR: 192.168.2.3
  SAS_EXTERNAL_HOSTNAME: sascas03.race.sas.com
  SAS_EXTERNAL_BIND_ADDR_IF: "eth0"
EOF
cd ~/sas_viya_playbook
ansible sas_casserver_primary,sas_casserver_worker -m file -a "path=/sastmp/cascache/d1 state=directory owner=cas group=sas mode=1777" -b -i DevCASSMP.inventory.ini
ansible sas_casserver_primary,sas_casserver_worker -m file -a "path=/sastmp/cascache/d2 state=directory owner=cas group=sas mode=1777" -b -i DevCASSMP.inventory.ini
cd ~/sas_viya_playbook
time ansible-playbook -i DevCASSMP.inventory.ini site.yml -e "@DevCASSMP.vars.yml" ; ansible sascas03 -i DevCASSMP.inventory.ini -m service -a "name=sas-viya-all-services.service enabled=no" -b > ./service.disable.log
