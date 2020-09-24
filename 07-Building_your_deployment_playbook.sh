mkdir -p /home/cloud-user/ViyaMirror/
cd /home/cloud-user/ViyaMirror/
curl -kO https://gelweb.race.sas.com/mirrors/yum/released/09QBTW/SAS_Viya_deployment_data.zip
cd /home/cloud-user/ViyaMirror/
# to uncomment after Viya 3.5 GA
curl -kO "https://support.sas.com/installation/viya/35/sas-orchestration-cli/lax/sas-orchestration-linux.tgz";tar -xvf sas-orchestration-linux.tgz
cd /home/cloud-user/ViyaMirror/
./sas-orchestration build --platform redhat --input SAS_Viya_deployment_data.zip --output SAS_Viya_playbook.tgz   --repository-warehouse https://gelweb.race.sas.com/mirrors/yum/released/09QBTW/sas_repos/
