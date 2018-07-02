#!/bin/bash
cd /tmp
wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tgz
tar -xzvf Python-3.6.1.tgz
cd Python-3.6.1
mkdir /usr/local/python3.6
./configure --prefix=/usr/local/python3.6
make
make install
cd ..
rm -rf /tmp/Python-3.6.1.tgz /tmp/Python-3.6.1

if [  -d "/tmp/Python-3.6.1" ]; then
  exit
fi

if [  -f "/tmp/Python-3.6.1.tgz" ]; then
  exit
fi

sudo pip install --upgrade pip
sudo pip install virtualenv
version_v=`virtualenv --version`
if [ ! -n "$version_v" ]; then
	echo "require virtualenv"
else    
	echo "your virtualenv is:$version_v"
fi


if [ ! -d "/usr/local/my_env36/" ];then
  mkdir /usr/local/my_env36/
fi

cd /usr/local/my_env36/

if [ ! -d "/usr/local/my_env36/venv" ];then
  virtualenv -p /usr/local/python3.6/bin/python3.6 venv
else
  rm -rf venv
  virtualenv -p /usr/local/python3.6/bin/python3.6 venv
fi
source ./venv/bin/activate
U_V1=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
if [ $U_V1 -ge 3 ]; then
	echo "your virtualenv is already"
fi
