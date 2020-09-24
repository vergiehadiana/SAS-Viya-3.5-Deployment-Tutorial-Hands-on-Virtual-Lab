cd ~/sas_viya_playbook

ansible httpproxy -m shell -a 'host=`hostname -f` ; cat /etc/httpd/conf.d/proxy.conf | grep ProxyPass | grep -e '/SAS' -e 'shared' | awk  "{print \$2}" | sort | uniq  | sed "s/^/https:\/\/"$host"/" ' | sed "s/int/sas/" | tee urls.txt
sudo lsof -nP -c cas  2>/dev/null |  grep '(deleted)'
cd ~/sas_viya_playbook
ansible-playbook viya-ark/playbooks/deployment-report/viya-deployment-report.yml
