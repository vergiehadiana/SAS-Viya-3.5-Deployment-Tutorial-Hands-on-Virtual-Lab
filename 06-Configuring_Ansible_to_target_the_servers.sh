cd ~
mkdir working
cd working
cat << 'EOF' > ./working.inventory.ini
[sas_all]
sasviya01 ansible_host=intviya01.race.sas.com
sasviya02 ansible_host=intviya02.race.sas.com
sasviya03 ansible_host=intviya03.race.sas.com
sascas01  ansible_host=intcas01.race.sas.com
sascas02  ansible_host=intcas02.race.sas.com
sascas03  ansible_host=intcas03.race.sas.com
EOF
cat << 'EOF' > ./ansible.cfg
[defaults]
log_path = ./working.log
inventory = working.inventory.ini
host_key_checking = true
forks = 10
retry_files_enabled = False
gathering = smart
remote_tmp = /tmp/.$USER.ansible/
EOF
ssh-keyscan -H intviya01.race.sas.com >> ~/.ssh/known_hosts
ssh-keyscan -H intviya02.race.sas.com >> ~/.ssh/known_hosts
ssh-keyscan -H intviya03.race.sas.com >> ~/.ssh/known_hosts
ssh-keyscan -H intcas01.race.sas.com >> ~/.ssh/known_hosts
ssh-keyscan -H intcas02.race.sas.com >> ~/.ssh/known_hosts
ssh-keyscan -H intcas03.race.sas.com >> ~/.ssh/known_hosts
