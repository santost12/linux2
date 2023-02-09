#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script as root"
  exit
fi

read -p "New hostname: " new_hostname

echo "You entered: " $new_hostname
read -p "Is this okay? (y/n) " confirmation

if [ $confirmation == "y" ]; then
  sed -i 's/ubuntutemplate/$new_hostname/g' /etc/hostname
  sed -i 's/ubuntutemplate/$new_hostname/g' /etc/hosts
else
  exit
fi

echo "Installing a few packages..."
sleep 1
sudo apt update
sudo apt install tmux htop nftables curl wget openssh-server -y

read -p "Do you want to regenerate the SSH server keys? (y/n) " sshd_regen_confirm

if [ $sshd_regen_confirmation == "y" ]; then
  rm -v /etc/ssh/ssh_host_*
  sudo dpkg-reconfigure openssh-server
fi

echo "Disabling and removing UFW..."
sleep 1
sudo ufw disable
sudo apt purge ufw -y

read -p "Do you want to download a firewall (nftables) template? (y/n)" firewall_template_confirm

if [ $firewall_template_confirmation == "y" ]; then
  echo "Are you running a desktop, router or server?"
  echo "For more examples, see: https://github.com/santost12/nftables-examples"
  read -p "Role? (d/r/s) " role

  if [ $role == "d" ]; then
    sudo curl https://raw.githubusercontent.com/santost12/nftables-examples/main/example-desktop.nft > /etc/nftables.conf
  elif [ $role == "r" ]; then
    sudo curl https://raw.githubusercontent.com/santost12/nftables-examples/main/example-router.nft > /etc/nftables.conf
  elif [ $role == "s" ]; then
    sudo curl https://raw.githubusercontent.com/santost12/nftables-examples/main/example-server2.nft > /etc/nftables.conf
  fi

fi

echo "Disabling password/ssh key remote root login..."
sleep 1
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
