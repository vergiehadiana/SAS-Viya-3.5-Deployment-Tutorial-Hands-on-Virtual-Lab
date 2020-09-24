cd ~/sas_viya_playbook
# check the service status.
ansible sas_all -b -m shell -a "/etc/init.d/sas-viya-all-services status"
ansible sas_all -m service -a "name=sas-viya-all-services.service enabled=no" -b
# disable SAS Studio Basic service
ansible programming -m service -a "name=sas-viya-sasstudio-default state=stopped enabled=no" -b
ansible programming -m shell -a "echo 'sas-viya-sasstudio-default' >> /opt/sas/viya/config/etc/viya-svc-mgr/svc-ignore" -b
cd ~/sas_viya_playbook
ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-status.yml
