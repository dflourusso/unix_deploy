#!/bin/bash

cd /opt/.unix_deploy

echo_blue "Verificando se \"unix_deploy\" esta atualizado"
sudo git remote update

if [ $(git rev-list HEAD...origin/master --count) -gt 0 ] ; then
  echo_red "\"unix_deploy\" desatualizado."
  echo_blue "Atualizando repositorio \"unix_deploy\"..."
  sudo git fetch --all
  sudo git reset --hard origin/master
fi
echo_green "\"unix_deploy\" atualizado."
cd -