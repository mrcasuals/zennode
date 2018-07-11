
#!/bin/bash
#step 3


export DEBIAN_FRONTEND=noninteractive

print_status() {
    echo
    echo "## $1"
    echo
}

if [ $# -ne 4 ]; then
    echo "Execution format ./install.sh stakeaddr email fqdn region (eu, na or sea)"
    exit
fi

# Installation variables
stakeaddr=${1}
email=${2}
fqdn=${3}
region=${4}


print_status "Installing the ZenCash node..."

echo "#########################"
echo "fqdn: $fqdn"
echo "email: $email"
echo "stakeaddr: $stakeaddr"
echo "#########################"

# Create swapfile if less then 4GB memory
totalmem=$(free -m | awk '/^Mem:/{print $2}')
totalswp=$(free -m | awk '/^Swap:/{print $2}')
totalm=$(($totalmem + $totalswp))
if [ $totalm -lt 6000 ]; then
  print_status "Server memory is less then 4GB..."
  if ! grep -q '/swapfile' /etc/fstab ; then
    print_status "Creating a 6GB swapfile..."
    fallocate -l 5G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
  fi
fi

echo "export FQDN=$FQDN" >> /home/$USER/.bashrc

sudo apt-get update -y

sudo apt-get install build-essential software-properties-common apt-transport-https lsb-release dirmngr pwgen ssl-cert git jq ufw curl -y

echo 'deb https://zencashofficial.github.io/repo/ '$(lsb_release -cs)' main' | sudo tee --append /etc/apt/sources.list.d/zen.list

gpg --keyserver ha.pool.sks-keyservers.net --recv 219F55740BBF7A1CE368BA45FB7053CE4991B669

gpg --export 219F55740BBF7A1CE368BA45FB7053CE4991B669 | sudo apt-key add -

sudo add-apt-repository ppa:certbot/certbot -y

sudo apt-get update -y

sudo apt-get install zen certbot -y

zen-fetch-params

zend

cat <<EOF > ~/.zen/zen.conf
rpcuser=$(pwgen -s 32 1)
rpcpassword=$(pwgen -s 64 1)
rpcport=18231
rpcallowip=127.0.0.1
rpcworkqueue=512
server=1
daemon=1
listen=1
txindex=1
logtimestamps=1
### testnet config
#testnet=1
EOF

#step 3 completed

#part 6 
#Firewall setup
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow http/tcp
sudo ufw allow https/tcp
sudo ufw allow 9033/tcp
sudo ufw logging on
sudo ufw -f enable
sudo ufw status

sudo systemctl enable ufw

#Certificate

sudo systemctl stop apache2
sudo systemctl disable apache2

sudo certbot certonly -n --agree-tos --register-unsafely-without-email --standalone -d $FQDN

sudo cp /etc/letsencrypt/live/$FQDN/chain.pem /usr/local/share/ca-certificates/chain.crt

sudo update-ca-certificates

echo "tlscertpath=/etc/letsencrypt/live/$FQDN/cert.pem" >> ~/.zen/zen.conf

echo "tlskeypath=/etc/letsencrypt/live/$FQDN/privkey.pem" >> ~/.zen/zen.conf

sudo adduser $USER ssl-cert

sudo chown -R root:ssl-cert /etc/letsencrypt/
sudo chmod -R 750 /etc/letsencrypt/

sg ssl-cert -c "bash"

zen-cli stop && sleep 5 && zend

	
sudo apt-get install npm -y && sudo npm install -g n && sudo n latest

	
mkdir -p ~/zencash && cd ~/zencash

git clone https://github.com/ZencashOfficial/secnodetracker.git

cd secnodetracker

npm install