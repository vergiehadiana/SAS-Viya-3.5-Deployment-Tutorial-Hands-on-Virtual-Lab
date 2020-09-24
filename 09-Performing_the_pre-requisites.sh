ansible localhost -m yum -a "name=git state=present" -b
ansible localhost -m yum -a "name=git state=present" -b
# Use VIYA-ARK
mkdir -p ~/working
cd ~/working
GIT_REPO=https://github.com/sassoftware/viya-ark.git
#BRANCH_TO_USE=Viya34-ark-1.7
BRANCH_TO_USE=Viya35-ark-1.0
git clone $GIT_REPO --branch $BRANCH_TO_USE --depth 1
ansible-playbook viya-ark/playbooks/pre-install-playbook/viya_pre_install_playbook.yml --list-tasks
cd ~/working
ansible-playbook viya-ark/playbooks/pre-install-playbook/viya_pre_install_playbook.yml \
-e 'use_pause=no' \
--tags selinux_config \
-e 'viya_version=3.4'
cd ~/working
ansible-playbook viya-ark/playbooks/pre-install-playbook/viya_pre_install_playbook.yml \
--skip-tags skipmemfail,skipcoresfail,skipstoragefail,skipnicssfail,bandwidth \
-e 'yum_cache_yn=1' \
-e 'use_pause=no' \
-e '{"custom_group_list": { "group": "sas" , "gid":"10001" } }' \
-e '{"custom_user_list": [ { "name": "cas" , "uid":"10002", "group":"sas" , "groups":"sas" } , { "name": "sas" , "uid":"10001", "group":"sas" , "groups":"sas" } ] }'
