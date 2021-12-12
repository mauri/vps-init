#!/bin/bash
# Initializes a VPS installation of Ubuntu 20.04
# 
# Based on https://github.com/TedLeRoy/first-ten-seconds-centos-ubuntu
#
# Consider this a live TODO list about what needs to happen when you get a new bare
# metal server and only have vnc root access.
# These lines can be handy when provisioning infrequently. There are more suitable
# tools to acomplish it such as https://www.ansible.com/ or https://www.chef.io/ 
#
set -euxo pipefail

# Tweak at will
USERNAME="ubuntu"
GITHUB_USER="mauri"
HOME_DIR="/home/${USERNAME}"

# Defining Colors for text output
_red=$( tput setaf 1 );
yellow=$( tput setaf 3 );
_green=$( tput setaf 2 );
normal=$( tput sgr 0 );

echo "${yellow}
Installing packages.
${normal}"
apt-get update
apt-get dist-upgrade
apt-get install -y ufw fail2ban net-tools

echo "${yellow}
Adding user ${USERNAME}.
${normal}"
useradd -m "${USERNAME}"
mkdir -p "${HOME_DIR}/.ssh"

echo "${yellow}
Configuring SSH.
${normal}"
curl "https://github.com/${GITHUB_USER}.keys" > "${HOME_DIR}/.ssh/authorized_keys"
chmod 400 "${HOME_DIR}/.ssh/authorized_keys"

chmod 700 "${HOME_DIR}/.ssh"
chown -R "${USERNAME}:${USERNAME}" "${HOME_DIR}/.ssh"

echo "${yellow}
Configuring sudoers.
${normal}"
echo "
${USERNAME} ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/11-vps-init

echo "${yellow}
Configuring sshd.
${normal}"
echo "DebianBanner no
Port 22022
DisableForwarding no
PermitRootLogin no
IgnoreRhosts yes
PasswordAuthentication no" | tee /etc/ssh/sshd_config.d/11-vps-init.conf
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
port     = 22022
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
findtime = 43200
bantime = 86400" | tee /etc/fail2ban/jail.local
systemctl restart fail2ban



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
