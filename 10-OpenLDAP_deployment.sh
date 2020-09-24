cd ~/working/
rm -rf ~/working/homegrown/
mkdir -p ~/working/homegrown/
cd ~/working/homegrown/
git clone https://gelgitlab.race.sas.com/GEL/tech-partners/openldap.git
ls -al openldap
cd ~/working/homegrown/openldap
cp inventory.ini inventory.ini.orig
cat << 'EOF' > ./inventory.ini
sasviya01 ansible_host=intviya01.race.sas.com
sasviya02 ansible_host=intviya02.race.sas.com
sasviya03 ansible_host=intviya03.race.sas.com
sascas01  ansible_host=intcas01.race.sas.com
sascas02  ansible_host=intcas02.race.sas.com
sascas03  ansible_host=intcas03.race.sas.com

[openldapserver]
sasviya01

[openldapclients]
sasviya01
sasviya02
sasviya03
sascas01
sascas02
sascas03


[openldapall:children]
openldapserver
openldapclients

EOF
cd ~/working/homegrown/openldap
ansible-playbook gel.openldapsetup.yml -e "OLCROOTPW=lnxsas" -e 'anonbind=true' -e 'use_pause=no'
## Check the OS knows about this account
ansible all -m shell -a "id viyademo01"
## is the account a local account (stored in /etc/passwd)?
ansible all -m shell -a "grep viyademo /etc/passwd"
## get more details about the account
ansible all -m shell -a "getent passwd viyademo01"
cat ~/working/homegrown/openldap/sitedefault.yml ; echo
