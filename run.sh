#!/bin/bash
###################

function _error {
	printf "\r${RED}ERROR:${NC}   ${1}\n" >&4
	if (( ${2:--1} > -1 )); then
		exit $2
	fi
}

function generate_cert {
	echo  "\n  generate_cert start... " 
	if ! which openssl > /dev/null 2>&1; then
		_info "OpenSSL not found. Skipping certificates.."
		return
	fi

	if [ ! -d "$HOME/.electrumx" ]; then
  	mkdir -p $HOME/.electrumx
	fi

	pushd .
	cd $HOME/.electrumx
	openssl genrsa -des3 -passout pass:xxxx -out server.pass.key 2048
	openssl rsa -passin pass:xxxx -in server.pass.key -out server.key
	rm server.pass.key
	openssl req -new -key server.key -batch -out server.csr
	openssl x509 -req -days 1825 -in server.csr -signkey server.key -out server.crt
	rm server.csr
	popd
	echo "\n  generate_cert end" 

}

function install_script_dependencies {
        apt-get update
        apt-get install -y openssl wget || _error "Could not install packages"
}

function check_pip_install_package {
	pip3 list | grep $1
}


function install_leveldb {
	apt-get install -y libleveldb-dev || _error "Could not install packages" 1
}

function  check_apt_install_package {
	apt list|grep -E $1
}
cd ~/btn-electrumx-server
install_script_dependencies

pip3 install -r requirements.txt

cat  requirements.txt | while read line
do

	echo "requirements.txt package installed: ${line} ?"
	a=$line
	a=$line
	echo "$a"
	if ! check_pip_install_package ${a}  > /dev/null 2>&1; then
		exit
	fi    
done

echo "requirements.txt package installed: libleveldb-dev?"
install_leveldb
if ! check_apt_install_package "libleveldb-dev"  > /dev/null 2>&1; then
		exit
	fi

		
ulimit -n 65535

export COIN=BTN
# http://user:password@127.0.0.1
# user  keep same with btnd btn.conf's rpcuser ; password keep same with  btnd btn.conf rpcpassword; 127.0.0.1 keep same with btnd btn.conf's rpcallowi  
export DAEMON_URL=http:///user:password@127.0.0.1
export NET=mainnet

echo "$HOME/.electrumx"
rm -rf $HOME/.electrumx
if [ ! -d "$HOME/.electrumx" ]; then
  mkdir -p $HOME/.electrumx
fi

export DB_DIRECTORY=$HOME/.electrumx/db
if [ ! -d $DB_DIRECTORY ]; then
  mkdir -p $DB_DIRECTORY
fi


export HOST=0.0.0.0

generate_cert

export SSL_KEYFILE=$HOME/.electrumx/server.key
export SSL_CERTFILE=$HOME/.electrumx/server.crt
export ALLOW_ROOT=true


nohup /usr/local/my_env36/venv/bin/python3.6 electrumx_server.py &
