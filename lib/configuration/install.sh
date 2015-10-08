#!/bin/bash

# Parar se ocorrer algum erro
set -e

echo -e "\033[34mInstalando plugin...\033[0m"

# Install git
if [ $(uname) == 'Linux' ] ; then
  type git || echo -e "\033[34mInstalando git...\033[0m" && apt-get update && apt-get install -y sudo git-core
fi

if [ -d ~/.unix_deploy ] ; then
  echo -e "\033[34mRepositorio ja existe. Atualizando...\033[0m"
  cd ~/.unix_deploy
  git fetch --all
  git reset --hard origin/master
  cd -
  echo -e "\033[32mAtualizado com sucesso!!!\033[0m"
else
  echo -e "\033[34mClonando repositorio...\033[0m"
  git clone https://github.com/dflourusso/unix_deploy.git ~/.unix_deploy
  echo -e "\033[32mClonado com sucesso!!!\033[0m"
fi

export_content='export PATH=$PATH:~/.unix_deploy/bin'
if [ -e ~/.bashrc ] ; then
  file=~/.bashrc
elif [ -e ~/.zshrc ] ; then
  file=~/.zshrc
elif [ -e ~/.bash_profile ] ; then
  file=~/.bash_profile
else
  echo -e "\033[31mNenhum arquivo encontrado para exportar o PATH do projeto\033[0m"
  echo -e "\033[33mUtilize \"~/.unix_deploy/<COMMAND>\" para executar alguma acao\033[0m"
fi

grep -q "$export_content" "$file" || echo "$export_content" >> "$file"
export PATH=$PATH:~/.unix_deploy/bin

echo -e "\033[32mAdicionado \"~/.unix_deploy/bin\" no PATH para suporte na linha de comando\033[0m"
