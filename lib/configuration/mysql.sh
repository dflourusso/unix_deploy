#!/bin/bash

# Parar se ocorrer algum erro
set -e

read  -p "Deseja instalar/reinstalar o \"mysql\"? (y/n): " install_mysql
if [ "$install_mysql" == 'y' ] ; then
  echo_blue "Instalando mysql..."

  sudo apt-get update
  sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev
  sudo mysql_install_db
  sudo mysql_secure_installation

  echo_blue "Instalando time_zone America/Sao_Paulo no mysql!"
  mysql_tzinfo_to_sql /usr/share/zoneinfo/America/Sao_Paulo America/Sao_Paulo | mysql -u root -p mysql

  echo_green "Mysql instalado com sucesso!"
fi
