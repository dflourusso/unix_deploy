#!/bin/bash

# Parar se ocorrer algum erro
set -e

# Adicionar usuarios no servidor
read -p "Deseja adicionar usuarios? (y/n): " add_user
while [[ "$add_user" == 'y' ]]
do
  read -p "Digite o nome do usuario: " user_name
  adduser $user_name
  echo_blue "Adicionando usuario \"$user_name\" no grupo \"sudo\"..."
  adduser $user_name sudo

  echo_blue "Adicionando sua public key no usuario \"$user_name\"..."
  mkdir -p /home/$user_name/.ssh
  sudo chown $user_name /home/$user_name/.ssh
  echo $id_rsa_pub >> /home/$user_name/.ssh/authorized_keys
  sudo chown $user_name /home/$user_name/.ssh/authorized_keys

  sudo -H -u $user_name bash -c "/opt/.unix_deploy/lib/configuration/rails_environment.sh"
  echo_green "Usuario $user_name adicionado e configurado com sucesso!"

  read -p "Adicionar mais usuarios? (y/n): " add_user
done
