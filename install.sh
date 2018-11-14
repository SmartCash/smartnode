#!/bin/bash
# install.sh
# Installs smartnode on Ubuntu 16.04 LTS x64
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

while true; do
 if [ -d ~/.smartcash ]; then
   printf "~/.smartcash/ already exists! The installer will delete this folder. Continue anyway? (y/n) "
   read REPLY
   if [ ${REPLY} == "Y" ] || [ ${REPLY} == "y" ]; then
      pID=$(ps -ef | grep smartcashd | grep -v grep | awk '{print $2}')
      kill ${pID} > /dev/null 2>&1
      rm -rf ~/.smartcash/
      break
   else
      if [ ${REPLY} == "N" ] || [ ${REPLY} == "n" ]; then
        exit
      fi
   fi
 else
   break
 fi
done

# Warning that the script will reboot the server
# echo "WARNING: This script will reboot the server when it's finished."
# printf "Press Ctrl+C to cancel or Enter to continue: "
# read IGNORE

cd
# Changing the SSH Port to a custom number is a good security measure against DDOS attacks
printf "Custom SSH Port(Enter to ignore): "
read VARIABLE
_sshPortNumber=${VARIABLE:-22}

# Get a new privatekey by going to console >> debug and typing smartnode genkey
printf "SmartNode GenKey: "
read _nodePrivateKey

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get the IP address of your vps which will be hosting the smartnode
_nodeIpAddress=$(curl -s 4.icanhazip.com)
if [[ ${_nodeIpAddress} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  external_ip_line="externalip=${_nodeIpAddress}:9678"
else
  external_ip_line="#externalip=external_IP_goes_here:9678"
fi

# Make a new directory for smartcash daemon
mkdir ~/.smartcash/
touch ~/.smartcash/smartcash.conf

# Change the directory to ~/.smartcash
cd ~/.smartcash/

# download bootstrap
# apt-get install unzip -y
# wget https://smartcash.cc/txindexstrap.zip
# unzip txindexstrap.zip
# rm txindexstrap.zip

# Create the initial smartcash.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
maxconnections=64
smartnode=1
$external_ip_line
smartnodeprivkey=${_nodePrivateKey}
" > smartcash.conf
cd

# Install smartcashd using apt-get
apt-get update -y
apt-get install software-properties-common -y
add-apt-repository ppa:smartcash/ppa -y && apt update -y && apt install smartcashd -y && smartcashd

# Create a directory for smartnode's cronjobs and the anti-ddos script
rm -r smartnode
mkdir smartnode

# Change the directory to ~/smartnode/
cd ~/smartnode/

# Download the appropriate scripts
wget https://raw.githubusercontent.com/SmartCash/smartnode/master/makerun.sh
wget https://raw.githubusercontent.com/SmartCash/smartnode/master/checkdaemon.sh
wget https://raw.githubusercontent.com/SmartCash/smartnode/master/upgrade.sh
wget https://raw.githubusercontent.com/SmartCash/smartnode/master/clearlog.sh

# Create a cronjob for making sure smartcashd runs after reboot
if ! crontab -l | grep "@reboot smartcashd"; then
  (crontab -l ; echo "@reboot smartcashd") | crontab -
fi

# Create a cronjob for making sure smartcashd is always running
if ! crontab -l | grep "~/smartnode/makerun.sh"; then
  (crontab -l ; echo "*/5 * * * * ~/smartnode/makerun.sh") | crontab -
fi

# Create a cronjob for making sure the daemon is never stuck
if ! crontab -l | grep "~/smartnode/checkdaemon.sh"; then
  (crontab -l ; echo "*/30 * * * * ~/smartnode/checkdaemon.sh") | crontab -
fi

# Create a cronjob for making sure smartcashd is always up-to-date
# if ! crontab -l | grep "~/smartnode/upgrade.sh"; then
#  (crontab -l ; echo "0 0 */1 * * ~/smartnode/upgrade.sh") | crontab -
# fi

# Create a cronjob for clearing the log file
if ! crontab -l | grep "~/smartnode/clearlog.sh"; then
  (crontab -l ; echo "0 0 */2 * * ~/smartnode/clearlog.sh") | crontab -
fi

# Give execute permission to the cron scripts
chmod 0700 ./makerun.sh
chmod 0700 ./checkdaemon.sh
chmod 0700 ./upgrade.sh
chmod 0700 ./clearlog.sh

# Change the SSH port
sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

# Firewall security measures
apt install ufw -y
ufw disable
ufw allow 9678
ufw allow "$_sshPortNumber"/tcp
ufw limit "$_sshPortNumber"/tcp
ufw logging on
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# Create aliases for commonly use smartcash-cli commands to ~/.bash_alises
if [ -e ~/.bash_aliases ]
then
    if grep -q "getinfo" ~/.bash_aliases
        then
        echo "Aliases already exist, not adding again..."
    else
	echo "Adding aliases for common smartcash-cli commands to ~/.bash_aliases"
        echo "
alias getinfo='smartcash-cli getinfo'
alias nodestatus='smartcash-cli smartnode status'
alias syncstatus='smartcash-cli snsync status'
alias restartnode='smartcash-cli stop && sleep 5 && smartcashd'
        " > ~/.bash_aliases
        echo "     getinfo for 'smartcash-cli getinfo'"
        echo "     nodestatus for 'smartcash-cli smartnode status'"
        echo "     syncstatus for 'smartcash-cli syncstatus'"
        echo "     restartnode for 'smartcash-cli stop && sleep 5 && smartcashd'"
        echo "     Please log out/in for these changes to take effect"
    fi

else
    echo "Adding aliases for common smartcash-cli commands to ~/.bash_aliases"
    echo "
alias getinfo='smartcash-cli getinfo'
alias nodestatus='smartcash-cli smartnode status'
alias syncstatus='smartcash-cli snsync status'
alias restartnode='smartcash-cli stop && sleep 5 && smartcashd'
    " > ~/.bash_aliases
    echo "     getinfo for 'smartcash-cli getinfo'"
    echo "     nodestatus for 'smartcash-cli smartnode status'"
    echo "     syncstatus for 'smartcash-cli syncstatus'"
    echo "     restartnode for 'smartcash-cli stop && sleep 5 && smartcashd'"
    echo "     Please log out/in for these changes to take effect"
fi

# Reboot the server
# reboot

# Since we not longer reboot here, reload the SSH config to active the
# custom port if selected
systemctl reload sshd
