cd ~/sas_viya_playbook
time ansible-playbook deploy-cleanup.yml
cd ~/sas_viya_playbook
#uninstall the httpd package
ansible httpproxy -m yum -a "name=httpd,mod_ssl state=absent" -b
cd ~/sas_viya_playbook
ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-stop.yml -e "enable_stray_cleanup=true"
ansible-playbook deploy-cleanup.yml -i DevCASSMP.inventory.ini  -e "@DevCASSMP.vars.yml"
cd ~/working/
ansible-playbook ~/GELVIYADEP35-deploying-viya-3.5-on-linux/scripts/playbooks/gel.poor.man.shared.fs.yml
ansible all -m shell -b -a "mount | grep share"
cd ~/sas_viya_playbook
#create a test file from sascas01
ansible sascas01 -m shell -a "touch /opt/sas/viya/config/data/cas/test.txt" -b
# list the file from sascas02
ansible sascas02 -m shell -a "ls -l /opt/sas/viya/config/data/cas/test.txt" -b
#Return to Viya Playbook directory
cd ~/sas_viya_playbook

cat << 'EOF' > ~/sas_viya_playbook/ha01.ini
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

# The CognitiveComputingServices host group contains services for performing common text analytics tasks.
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

[StudioViya]
sasviya01
sasviya02
sasviya03

[ThemeServices]
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
cd ~/sas_viya_playbook/
ansible localhost -m lineinfile -a "dest=ansible.cfg regexp='inventory' line='inventory = ha01.ini'"
cd ~/sas_viya_playbook
ansible httpproxy -m yum -a "name=httpd,mod_ssl state=present" -b
ansible httpproxy -m get_url -a "dest=/etc/pki/tls/certs/  url=https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/TLS/MergedCA.cer" -b

ansible httpproxy -m get_url -a "dest=/etc/pki/tls/certs/  url=https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/TLS/ca_cert.pem" -b

#Get web server cert and key
ansible httpproxy -m get_url -a "dest=/etc/pki/tls/certs/  url=https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/TLS/web_server_cert.pem" -b

ansible httpproxy -m get_url -a "dest=/etc/pki/tls/private/  url=https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/TLS/web_server_key.pem " -b
ansible httpproxy -m replace -a "dest=/etc/httpd/conf.d/ssl.conf regexp='localhost.crt' replace='web_server_cert.pem' " -b
ansible httpproxy -m replace -a "dest=/etc/httpd/conf.d/ssl.conf regexp='localhost.key' replace='web_server_key.pem' " -b
#Restart apache:
ansible httpproxy -m service -a "name=httpd state=restarted enabled=yes" -b
#Test the https access with the merged certificate (copy paste the lines one by one.):
openssl s_client -quiet -connect sasviya01.race.sas.com:443 -CAfile /etc/pki/tls/certs/MergedCA.cer

openssl s_client -quiet -connect sasviya02.race.sas.com:443 -CAfile /etc/pki/tls/certs/MergedCA.cer

openssl s_client -quiet -connect sasviya03.race.sas.com:443 -CAfile /etc/pki/tls/certs/MergedCA.cer
ansible sascas03 -m yum -a "name=haproxy state=present" -b
ansible sascas03 -m get_url -a "dest=/etc/pki/tls/certs/  url=https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/TLS/haproxy.pem" -b

ansible sascas03 -m get_url -a "dest=/etc/pki/tls/certs/  url=https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/TLS/MergedCA.cer" -b

ansible sascas03 -m get_url -a "dest=/etc/haproxy/  url=https://gelweb.race.sas.com/scripts/GELVIYADEP35_001/haproxy.cfg" -b
ansible sascas03 -m service -a "name=haproxy state=started enabled=yes" -b
cd ~/sas_viya_playbook
cp vars.yml vars.yml.split
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "dest=vars.yml regexp='  sasviya02' line='  sasviya01:'"
ansible localhost -m lineinfile -a "dest=vars.yml regexp='- NODE_NUMBER' line='    - NODE_NUMBER: '2''"
cat > /tmp/insertPGHABlock.yml << EOF
---
- hosts: sasviya01

  tasks:
  - name: Insert PostgreSQL HA block
    blockinfile:
      path: ~/sas_viya_playbook/vars.yml
      insertafter: "      SERVICE_NAME: postgres"
      block: |2
          sasviya02:
            sasdatasvrc:
            - NODE_NUMBER: '1'
              PG_PORT: '5432'
              SANMOUNT: '{{ SAS_CONFIG_ROOT }}/data/sasdatasvrc'
              SERVICE_NAME: postgres
          sasviya03:
            sasdatasvrc:
            - NODE_NUMBER: '0'
              PG_PORT: '5432'
              SANMOUNT: '{{ SAS_CONFIG_ROOT }}/data/sasdatasvrc'
              SERVICE_NAME: postgres
EOF
ansible-playbook /tmp/insertPGHABlock.yml
ansible localhost -m lineinfile -a "dest=~/sas_viya_playbook/vars.yml regexp='^HTTPD_CERT_PATH' line='HTTPD_CERT_PATH: \"/etc/pki/tls/certs/MergedCA.cer\"'" --diff
ansible localhost -m lineinfile -a "dest=~/sas_viya_playbook/vars.yml regexp='SERVICESBASEURL:' line='     SERVICESBASEURL: \'https://sascas03.race.sas.com\''" --diff
ansible programming,ComputeServer -m file -a "name=/sastmp/saswork state=directory owner=sas group=sas mode=1777" -b
#uninstall OpenLDAP
cd ~/working/homegrown/openldap
ansible-playbook gel.openldapremove.yml

#re-install OpenLDAP
ansible-playbook gel.openldapsetup.yml -e "OLCROOTPW=lnxsas" -e 'anonbind=true' -e 'homedir=/sharedhome' -e 'use_pause=no'
cd ~/sas_viya_playbook
time ansible-playbook site.yml ; ansible sas_all -m service -a "name=sas-viya-all-services.service enabled=no" -b > ./service.disable.log
#prepare the environment
. /opt/sas/viya/config/consul.conf
export CONSUL_TOKEN=$(sudo cat /opt/sas/viya/config/etc/SASSecurityCertificateFramework/tokens/consul/default/client.token)
#this is for the launcher server
/opt/sas/viya/home/bin/sas-bootstrap-config kv write --force config/launcher-server/global/sas-services-url https://sascas03.race.sas.com:443/
#this is for report services
/opt/sas/viya/home/bin/sas-bootstrap-config kv write --force config/viya/sas.httpproxy.external.hostname sascas03.race.sas.com
ansible httpproxy -m service -a "name=sas-viya-httpproxy-default state=restarted" -b
ansible ComputeServer -m service -a "name=sas-viya-runlauncher-default state=restarted" -b
ansible ReportServices -m service -a "name=sas-viya-reportdistribution-default state=restarted" -b
cd ~/sas_viya_playbook/
ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-status.yml
cd ~/sas_viya_playbook/
ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-status.yml | grep -E -i 'down|dead|not\ ready'
# disable SAS Studio Basic service
ansible programming -m service -a "name=sas-viya-sasstudio-default state=stopped enabled=no" -b
ansible programming -m shell -a "echo 'sas-viya-sasstudio-default' >> /opt/sas/viya/config/etc/viya-svc-mgr/svc-ignore" -b
ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-status.yml
curl -kv https://localhost:443
sudo apachectl status
