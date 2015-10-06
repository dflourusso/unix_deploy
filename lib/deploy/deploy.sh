#!/bin/bash

# Parar se ocorrer erro
set -e

APP_NAME=$1

echo ''
echo $'\e[32m###################################\e[0m'
echo "Deploy na aplicacao $APP_NAME"
echo $'\e[32m###################################\e[0m'
echo ''

if [ -d ~/apps/$APP_NAME ] ; then
  # Ir para diretorio do projeto
  cd ~/apps/$APP_NAME/

  echo $'\e[34mAtualizando repositorio...\e[0m'
  # Baixa atualizacoes sobrescrevendo todas as alteracoes locais
  git fetch --all
  git reset --hard origin/master

  echo $'\e[34mInstalando dependencias da aplicacao...\e[0m'
  /home/$USER/.rbenv/shims/bundle install --deployment --without development test

  # Compilar assets, remover assets antigos, executar migracao do banco de dados
  echo $'\e[34mCompilando assets, removendo assets antigos, executando migracao do banco de dados...\e[0m'
  /home/$USER/.rbenv/shims/bundle exec rake assets:precompile assets:clean db:migrate RAILS_ENV=production

  echo $'\e[34mReiniciando aplicacao...\e[0m'
  /usr/bin/passenger-config restart-app $(pwd)

  echo $'\e[32mDeploy executado com sucesso!\e[0m'

else

  echo $'\e[34mAplicacao nao existe\e[0m'
  echo $'\e[34mCriando e configurando aplicacao...\e[0m'

  # Criar pasta apps se nao existir
  mkdir -p ~/apps

  # Ir para pasta apps
  cd ~/apps

  # Clonar projeto
  echo 'Entre com a URL do repositorio de seu projeto'
  read  -p "Tenha certeza que tem acesso a ele: " APP_REPOSITORY
  echo $'\e[34mClonando projeto...\e[0m'
  git clone $APP_REPOSITORY $APP_NAME

  # Ir para pasta do projeto
  cd $APP_NAME

  echo $'\e[34mInstalando dependencias da aplicacao...\e[0m'
  /home/$USER/.rbenv/shims/bundle install --deployment --without development test


  # Configuracao do NGINX
  echo $'\e[34mConfigurando nginx...\e[0m'
  export APP_NGINX_CONF="/etc/nginx/sites-enabled/$APP_NAME.conf"
  sudo wget -O $APP_NGINX_CONF https://gist.githubusercontent.com/dflourusso/bd8103650bc240dd02d6/raw/8a1f8b1e4910c94a47b251445a36194f58bef7ad/digital-ocean-debian-nginx.conf

  while [[ -z "$APP_DOMAIN" ]]
  do
    echo 'Dominio nao pode ser vazio'
    read  -p "Entre com um dominio para sua aplicacao: " APP_DOMAIN
  done

  sudo /usr/bin/replace '[app_name]' $APP_NAME -- $APP_NGINX_CONF
  sudo /usr/bin/replace '[server_name]' $APP_DOMAIN -- $APP_NGINX_CONF
  sudo /usr/bin/replace '[user_name]' $USER -- $APP_NGINX_CONF


  # Variaveis de ambiente
  sudo /usr/bin/replace '}' '' -- $APP_NGINX_CONF

  SECRET_KEY_BASE_VALUE=$(RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake secret)
  echo -e "    passenger_env_var SECRET_KEY_BASE $SECRET_KEY_BASE_VALUE;" | sudo tee --append $APP_NGINX_CONF
  echo -e "Criado variavel de ambiente: SECRET_KEY_BASE\n"

  echo -e "    passenger_env_var DATABASE_NAME $APP_NAME;" | sudo tee --append $APP_NGINX_CONF
  echo -e "Criado variavel de ambiente: DATABASE_NAME=$APP_NAME\n"

  read -p "Qual a senha do banco de dados?: " DATABASE_PASSWORD
  echo -e "    passenger_env_var DATABASE_PASSWORD $DATABASE_PASSWORD;" | sudo tee --append $APP_NGINX_CONF
  echo -e "Criado variavel de ambiente: DATABASE_PASSWORD\n"

  read -p "Deseja adicionar mais variaveis de ambiente? (y/n): " ENV_VARS

  while [[ "$ENV_VARS" != 'n' ]]
  do
    read -p "Nome da variavel: " ENV_VAR_NAME
    read -p "Valor da variavel: " ENV_VAR_VALUE
    echo -e "    passenger_env_var $ENV_VAR_NAME $ENV_VAR_VALUE;" | sudo tee --append $APP_NGINX_CONF
    read -p "Adicionar mais? (y/n): " ENV_VARS
  done
  echo -e "\n}" | sudo tee --append $APP_NGINX_CONF

  echo $'\e[34mReiniciando nginx...\e[0m'
  sudo service nginx restart


  # Compilar assets, remover assets antigos, executar migracao do banco de dados
  echo $'\e[34mCriando banco de dados...\e[0m'
  RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake db:create

  echo $'\e[34mCarrega o schema do banco de dados...\e[0m'
  RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake db:schema:load

  echo $'\e[34mCompilando assets...\e[0m'
  RAILS_ENV=production /home/$USER/.rbenv/shims/bundle exec rake assets:precompile assets:clean

  # Iniciando aplicacao
  /usr/bin/curl $APP_DOMAIN > /dev/null

  echo $'\e[32mDeploy executado com sucesso!\e[0m'
fi
