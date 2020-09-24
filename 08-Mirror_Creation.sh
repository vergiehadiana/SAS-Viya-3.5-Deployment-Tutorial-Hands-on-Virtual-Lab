mkdir -p /home/cloud-user/ViyaMirror/
cd /home/cloud-user/ViyaMirror/
curl -kO https://gelweb.race.sas.com/mirrors/yum/released/09QBTW/SAS_Viya_deployment_data.zip
cd /home/cloud-user/ViyaMirror/
curl -kO "https://support.sas.com/installation/viya/35/sas-mirror-manager/lax/mirrormgr-linux.tgz"
tar -xvf mirrormgr-linux.tgz
cd /home/cloud-user/ViyaMirror/
./mirrormgr mirror \
    --deployment-data ./SAS_Viya_deployment_data.zip \
    --path /home/cloud-user/ViyaMirror/ \
    --platform x64-redhat-linux-6 \
    --latest --workers 10 \
    --insecure --url "https://gelweb.race.sas.com/mirrors/yum/released/09QBTW/sas_repos"
#Do not run this
#python -m SimpleHTTPServer 8123 &
# install ComplexHTTPServer
sudo pip install ComplexHTTPServer
cd ~/ViyaMirror/
nohup python -m ComplexHTTPServer 8123 > /dev/null 2>/dev/null  &
