cat > /tmp/insertHiveHostsBlock.yml << EOF
---
- hosts: localhost,sas_casserver_primary,programming
  tasks:
  - name: Insert Hadoop Hosts block for remote CAS access
    blockinfile:
      path: /etc/hosts
      backup: yes
      insertafter: EOF
      block: |
        10.96.8.245 sashdp02.race.sas.com sashdp02
        10.96.5.184 sashdp01.race.sas.com sashdp01
EOF
cd ~/sas_viya_playbook
ansible-playbook /tmp/insertHiveHostsBlock.yml --diff -b
cd ~/sas_viya_playbook
LATEST_INV=$(ls -alrt ~/sas_viya_playbook | grep .ini | grep -v remote_hdfs.ini | tail -1 | awk '{print $9}')
cd ~/sas_viya_playbook
cp $LATEST_INV inventory_htracer.ini
cd ~/sas_viya_playbook
ansible localhost -m lineinfile -a "insertbefore=BOF path=inventory_htracer.ini line='hiveserver ansible_host=sashdp02.race.sas.com ansible_ssh_common_args=\'-o StrictHostKeyChecking=no\''" --diff
cd ~/sas_viya_playbook
ansible localhost -m ini_file -a "path=~/sas_viya_playbook/inventory_htracer.ini section=hadooptracr1 option=hiveserver allow_no_value=yes" --diff
cd ~/sas_viya_playbook
ansible sas_casserver_primary:programming -m file -a "dest=/tmp/hadoop_deployment state=directory"
cd ~/sas_viya_playbook
time ansible-playbook utility/hadooptracer-launch.yml -i inventory_htracer.ini
cd ~/sas_viya_playbook
ansible sascas* -m lineinfile -a "path=/opt/sas/viya/config/etc/cas/default/cas_usermods.settings create=yes backup=yes line='export JAVA_HOME=/usr/lib/jvm/jre-1.8.0\nexport LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$JAVA_HOME/lib/amd64/server'" -b --diff
cd ~/sas_viya_playbook
ansible sascas01 -m shell -a "systemctl stop sas-viya-cascontroller-default" -b
sleep 10
cd ~/sas_viya_playbook
ansible sascas01 -m shell -a "systemctl start sas-viya-cascontroller-default" -b
cd ~/sas_viya_playbook
ansible-playbook utility/hadooptracer-validation.yml -i inventory_htracer.ini
