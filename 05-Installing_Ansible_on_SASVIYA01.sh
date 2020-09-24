sudo yum repolist
## find out which release (6 or 7)
if grep -q -i "release 6" /etc/redhat-release ; then
majversion=6
elif grep -q -i "release 7" /etc/redhat-release ; then
majversion=7
else
echo "Apparently, running neither release 6.x nor 7.x "
fi

## Verify the previous command:
echo $majversion

## Attach EPEL
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$majversion.noarch.rpm
sudo yum repolist
## install pip
sudo yum install -y python-pip gcc python-devel
sudo pip install --upgrade pip 'setuptools==44'
## use pip instead of Yum, to install a specific ansible version
sudo pip install 'ansible==2.8.6'
ansible --version
ansible localhost -m ping
