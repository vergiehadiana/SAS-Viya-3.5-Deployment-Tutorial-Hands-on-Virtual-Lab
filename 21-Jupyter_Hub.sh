cd ~/working
# to be converted to playbook
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
sudo yum install python-pip
sudo yum install bzip2 -y
cd /opt
sudo curl -O https://repo.continuum.io/archive/Anaconda3-2019.10-Linux-x86_64.sh
sudo bash Anaconda3-2019.10-Linux-x86_64.sh -b -p /opt/anaconda3
sudo /opt/anaconda3/bin/pip install https://github.com/sassoftware/python-swat/releases/download/v1.6.1/python-swat-1.6.1-linux64.tar.gz
sudo /opt/anaconda3/bin/pip install sas_kernel
export CFGPYFILE=/opt/anaconda3/lib/python3.7/site-packages/saspy/sascfg.py
# backup the sas kernel config file
sudo cp $CFGPYFILE $CFGPYFILE.orig

# update saspath in the configuration file
sudo sed -i.bak2 "s/default.*{'saspath'.*/default  \= {'saspath'  : '\/opt\/sas\/spre\/home\/bin\/sas'/"  $CFGPYFILE
# update saspath in the configuration file
sudo sed -i.bak2 "s/ssh.*{'saspath'.*/ssh      \= {'saspath'  : '\/opt\/sas\/spre\/home\/bin\/sas',/"  $CFGPYFILE
# show the file content, the saspath should be set correctly
cat $CFGPYFILE
# install nodeJS
sudo yum install nodejs -y
# install configurable-http-proxy
sudo npm install -g configurable-http-proxy
sudo /opt/anaconda3/bin/pip install jupyterhub
sudo mkdir /opt/anaconda3/etc/jupyterhub
sudo rm -f /opt/anaconda3/etc/jupyterhub/jupyterhub_config.py
sudo touch /opt/anaconda3/etc/jupyterhub/jupyterhub_config.py
sudo /opt/anaconda3/bin/jupyterhub --generate-config -f /opt/anaconda3/etc/jupyterhub/jupyterhub_config.py
sudo bash -c "cat << EOF >> /opt/anaconda3/etc/jupyterhub/jupyterhub_config.py
#c.JupyterHub.confirm_no_ssl = True
c.JupyterHub.cookie_secret_file = '/opt/anaconda3/var/cookie_secret'
c.JupyterHub.pid_file = '/opt/anaconda3/var/jupyterhub.pid'
c.JupyterHub.cleanup_servers = True
c.JupyterHub.cleanup_proxy = True
## this is sometimes required.
c.Spawner.env_keep.append('CAS_CLIENT_SSL_CA_LIST')
c.Spawner.cmd = ['/opt/anaconda3/bin/jupyterhub-singleuser']
EOF"

sudo su -
echo 'export PATH="/opt/anaconda3/bin:$PATH"' >> ~/.bashrc
echo 'export CAS_CLIENT_SSL_CA_LIST=/opt/sas/viya/config/etc/SASSecurityCertificateFramework/cacerts/vault-ca.crt' >> ~/.bashrc

#source .bashrc to pick up environment variable
. ~/.bashrc
ll $CAS_CLIENT_SSL_CA_LIST
#start it up (sync)
#/opt/anaconda3/bin/jupyterhub -f /opt/anaconda3/etc/jupyterhub/jupyterhub_config.py

#start it up (async)
nohup /opt/anaconda3/bin/jupyterhub -f /opt/anaconda3/etc/jupyterhub/jupyterhub_config.py &
exit
# create a python test program
cat << EOF > ~/castest.py
import swat
conn = swat.CAS('sascas01',5570, 'viyademo01', 'lnxsas', caslib="casuser")
# Get the csv file from SAS support documentation
castbl = conn.read_csv('http://support.sas.com/documentation/onlinedoc/viya/exampledatasets/hmeq.csv', casout = 'hmeq')
print(conn)
out = conn.serverstatus()
print(out)
conn.close()
EOF
echo 'export CAS_CLIENT_SSL_CA_LIST=/opt/sas/viya/config/etc/SASSecurityCertificateFramework/cacerts/vault-ca.crt' >> ~/.bashrc

#source .bashrc to pick up environment variable
. ~/.bashrc

# Verify that the certificate file is available
ll $CAS_CLIENT_SSL_CA_LIST

# execute the test program
/opt/anaconda3/bin/python ~/castest.py
