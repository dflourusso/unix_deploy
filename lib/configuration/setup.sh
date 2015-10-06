#!/bin/bash

# Parar se ocorrer algum erro
set -e

echo_blue "Instalando configuracoes basicas do servidor..."

# Install basic
apt-get update
apt-get install -y sudo vim curl wget htop zip apt-transport-https ca-certificates

# Add Swap to server
if [ ! -e /swapfile ] ; then
  read  -p "Deseja adicionar memoria swap no servidor? (y/n): " add_swap
  if [ "$add_swap" == 'y' ] ; then
    echo_yellow "Adicionando memoria SWAP no servidor..."
    read -p "Que quantidade de memoria deseja adicionar? (Ex: 1024): " memoria_swap
    sudo dd if=/dev/zero of=/swapfile bs=1024 count="$memoria_swap"k
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo echo "\n/swapfile       none    swap    sw      0       0" >> /etc/fstab
    echo 10 | sudo tee /proc/sys/vm/swappiness
    echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
    sudo chown root:root /swapfile
    sudo chmod 0600 /swapfile
    sudo swapon -s
    echo_green "Memoria SWAP adicionada com sucesso!"
  fi
fi

# Root
echo_yellow "Adicionando sua public key usuario \"root\"..."
mkdir -p ~/.ssh
if [ ! -f ~/.ssh/authorized_keys ]; then
    touch ~/.ssh/authorized_keys
fi
if grep -q "$id_rsa_pub" ~/.ssh/authorized_keys ; then
    echo "App $id_rsa_pub ja existe."
else
    echo $id_rsa_pub >> ~/.ssh/authorized_keys
fi

