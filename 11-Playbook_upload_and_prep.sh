cd ~
curl -o ~/SAS_Viya_playbook.tgz --insecure https://gelweb.race.sas.com/mirrors/yum/released/09QBTW/SAS_Viya_playbook.tgz
cd ~

# extract the Viya playbook
tar xvf SAS_Viya_playbook.tgz

# list the content of the Viya deployment playbook
cd sas_viya_playbook
ls -al

#backup vars.yml and inventory.
cp vars.yml vars.yml.orig
cp inventory.ini inventory.ini.orig
cd ~/sas_viya_playbook
chmod u+w ansible.cfg
# copy the sitedefault.yml file to pre-configure the authentication
cp ~/working/homegrown/openldap/sitedefault.yml  ~/sas_viya_playbook/roles/consul/files/
cp -R ~/working/viya-ark/ ~/sas_viya_playbook
