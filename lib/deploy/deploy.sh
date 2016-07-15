#!/bin/bash

# Parar se ocorrer erro
set -e

APP_NAME=$1

source $(dirname $(dirname $(dirname $0)))"/utils/colors.sh"
source $(dirname $(dirname $(dirname $0)))"/utils/self_update.sh"

self_update

echo ''
echo $'\e[32m###################################\e[0m'
echo "Deploy na aplicacao $APP_NAME"
echo $'\e[32m###################################\e[0m'
echo ''

_whenever() {
  if [ -f config/schedule.rb ]; then
    echo $'\e[34mWhenever atualizando crontab...\e[0m'
    RAILS_ENV=production /home/$USER/.rbenv/shims/whenever --update-crontab
  fi
}

_add_env_var() {
  read -p "Nome da variavel de ambiente: " ENV_VAR_NAME
  read -p "Valor da variavel de ambiente: " ENV_VAR_VALUE
  echo -e "$ENV_VAR_NAME=$ENV_VAR_VALUE" | sudo tee --append $1
}

_env_var_defaults() {
  SECRET_KEY_BASE_VALUE=$(RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake secret)
  echo -e "SECRET_KEY_BASE=$SECRET_KEY_BASE_VALUE" | sudo tee --append $1
  echo -e "Criado variavel de ambiente: SECRET_KEY_BASE\n"

  echo -e "HOST_NAME=$APP_DOMAIN" | sudo tee --append $1
  echo -e "Criado variavel de ambiente: HOST_NAME=$APP_DOMAIN\n"

  echo -e "DATABASE_NAME=$APP_NAME" | sudo tee --append $1
  echo -e "Criado variavel de ambiente: DATABASE_NAME=$APP_NAME\n"

  read -p "Qual a senha do banco de dados?: " DATABASE_PASSWORD
  echo -e "DATABASE_PASSWORD=$DATABASE_PASSWORD" | sudo tee --append $1
  echo -e "Criado variavel de ambiente: DATABASE_PASSWORD\n"
}

_restart() {
  if grep -Fq "gem 'thin'" /home/$USER/apps/$APP_NAME/Gemfile
  then
    echo $'\e[34mReiniciando aplicacao (Thin + Nginx)...\e[0m'
    bash /etc/init.d/thin restart
    sudo /etc/init.d/nginx force-reload && sudo /etc/init.d/nginx restart
  else
    echo $'\e[34mReiniciando aplicacao (Passenger + Nginx)...\e[0m'
    sudo service nginx restart
    sudo /usr/bin/passenger-config restart-app $(pwd)
  fi
}

if [ -d /home/$USER/apps/$APP_NAME ] ; then
  # Ir para diretorio do projeto
  cd /home/$USER/apps/$APP_NAME/

  echo $'\e[34mAtualizando repositorio...\e[0m'
  # Baixa atualizacoes sobrescrevendo todas as alteracoes locais
  git fetch --all
  git reset --hard origin/master

  echo $'\e[34mInstalando dependencias da aplicacao...\e[0m'
  /home/$USER/.rbenv/shims/bundle install --deployment --without development test

  # Compilar assets, remover assets antigos, executar migracao do banco de dados
  echo $'\e[34mCompilando assets, removendo assets antigos, executando migracao do banco de dados...\e[0m'
  /home/$USER/.rbenv/shims/bundle exec rake assets:precompile assets:clean db:migrate RAILS_ENV=production

  _whenever
  _restart

  echo $'\e[32mDeploy executado com sucesso!\e[0m'

else

  echo $'\e[34mAplicacao nao existe\e[0m'
  echo $'\e[34mCriando e configurando aplicacao...\e[0m'

  # Criar pasta apps se nao existir
  mkdir -p /home/$USER/apps

  # Ir para pasta apps
  cd /home/$USER/apps

  # Clonar projeto
  echo -e "\033[34mId rsa para adicionar no 'deployment keys' de seu projeto: \033[0m$(cat /home/$USER/.ssh/id_rsa.pub)"
  echo 'Entre com a URL do repositorio de seu projeto'
  read  -p "Tenha certeza que tem acesso a ele: " APP_REPOSITORY
  echo $'\e[34mClonando projeto...\e[0m'
  git clone $APP_REPOSITORY $APP_NAME

  # Ir para pasta do projeto
  cd $APP_NAME

  echo $'\e[34mInstalando dependencias da aplicacao...\e[0m'
  /home/$USER/.rbenv/shims/bundle install --deployment --without heroku development test console

  while [[ -z "$APP_DOMAIN" ]]
  do
    echo 'Dominio nao pode ser vazio'
    read  -p "Entre com um dominio para sua aplicacao: " APP_DOMAIN
  done

  # Configuracao do NGINX
  echo $'\e[34mConfigurando nginx...\e[0m'
  export APP_NGINX_CONF="/etc/nginx/sites-available/$APP_NAME.conf"
  export APP_ENV_VARS_CONF="/home/$USER/apps/.$APP_NAME.vars"

  echo_blue "Qual ruby server está utilizando?"
  echo_blue " 1 - Passenger"
  echo_blue " 2 - Thin"
  read -p "(1/2): " SERVER_TYPE
  if [ "$SERVER_TYPE" == '1' ] ; then
    sudo cp /home/$USER/.unix_deploy/lib/configuration/templates/passenger-nginx.conf $APP_NGINX_CONF
  else
    sudo /home/$USER/.rbenv/shims/thin config -C /etc/thin/$APP_NAME.yml -c /home/$USER/apps/$APP_NAME --servers 3 -e production
    sudo cp /home/$USER/.unix_deploy/lib/configuration/templates/thin-nginx.conf $APP_NGINX_CONF
    sudo ln -nfs $APP_NGINX_CONF /etc/nginx/sites-enabled/$APP_NAME
  fi

  sudo /usr/bin/replace '[app_name]' $APP_NAME -- $APP_NGINX_CONF
  sudo /usr/bin/replace '[server_name]' $APP_DOMAIN -- $APP_NGINX_CONF
  sudo /usr/bin/replace '[user_name]' $USER -- $APP_NGINX_CONF

  # Variaveis de ambiente

  _env_var_defaults $APP_ENV_VARS_CONF

  read -p "Deseja adicionar mais variaveis de ambiente? (y/n): " ENV_VARS

  while [[ "$ENV_VARS" != 'n' ]]
  do
    _add_env_var $APP_ENV_VARS_CONF
    read -p "Adicionar mais variaveis de ambiente? (y/n): " ENV_VARS
  done

  # Compilar assets, remover assets antigos, executar migracao do banco de dados
  echo $'\e[34mCriando banco de dados...\e[0m'
  RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake db:create

  echo $'\e[34mCarregando o schema do banco de dados...\e[0m'
  RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake db:schema:load

  echo $'\e[34mCompilando assets...\e[0m'
  RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake assets:precompile assets:clean

  _whenever
  _restart

  # Iniciando aplicacao
  /usr/bin/curl $APP_DOMAIN > /dev/null

  echo $'\xf0\x9f\x8d\xba \e[32m Deploy executado com sucesso!\e[0m'
fi
