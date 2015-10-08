#!/bin/bash

self_update() {
  cd ~/.unix_deploy

  echo_blue "Verificando se \"unix_deploy\" esta atualizado"
  git remote update

  if [ $(git rev-list HEAD...origin/master --count) -gt 0 ] ; then
    echo_red "\"unix_deploy\" desatualizado."
    echo_blue "Atualizando repositorio \"unix_deploy\"..."
    git fetch --all
    git reset --hard origin/master
  fi
  echo_green "\"unix_deploy\" atualizado."
  cd -
}