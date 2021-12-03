#!/bin/bash
# Initializes a VPS installation of Ubuntu 20.04
# 
# Based on https://github.com/TedLeRoy/first-ten-seconds-centos-ubuntu

set -euxo pipefail

# Tweak at will
USERNAME="ubuntu"
GITHUB_USER="mauri"
HOME_DIR="/home/${USERNAME}"

# Defining Colors for text output
red=$( tput setaf 1 );
yellow=$( tput setaf 3 );
green=$( tput setaf 2 );
normal=$( tput sgr 0 );

echo "${yellow}
Installing packages.
${normal}"
apt-get update
apt-get install -y ufw fail2ban net-tools

echo "${yellow}
Adding user ${USERNAME}.
${normal}"
useradd "${USERNAME}"
mkdir "${HOME_DIR}"
mkdir "${HOME_DIR}/.ssh"
chmod 700 "${HOME_DIR}/.ssh"

echo "${yellow}
Configuring SSH.
${normal}"
curl "https://github.com/${GITHUB_USER}.keys > "${HOME_DIR}/.ssh/authorized_keys
chmod 400 "${HOME_DIR}/.ssh/authorized_keys"

echo "DebianBanner no
Port 22022
DisableForwarding yes
PermitRootLogin no
IgnoreRhosts yes
PasswordAuthentication no" | sudo tee /etc/ssh/sshd_config.d/11-vps-init.conf
systemctl reload ssh

echo "${yellow}
Configuring fail2ban.
${normal}"
echo "# Default banning action (e.g. iptables, iptables-new,
# iptables-multiport, shorewall, etc) It is used to define
# action_* variables. Can be overridden globally or per
# section within jail.local file
[ssh]
enabled  = true
banaction = iptables-multiport
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
findtime = 43200
bantime = 86400" | sudo tee /etc/fail2ban/jail.local
sudo systemctl restart fail2ban


exit 0

  # # Enabling ufw firewall and making sure it allows SSH
  # echo "${yellow}  Enabling ufw firewall. Ensuring SSH is allowed.
  # ${normal}"
  # sudo ufw allow ssh
  # sudo ufw --force enable
  # echo "${green}
  # Done configuring ufw firewall.
  # ${normal}"
  # #Pausing so user can see output
  # sleep 1
