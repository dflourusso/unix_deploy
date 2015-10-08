#!/bin/bash

#Tutorial para debian 8 (Jessie)

# Parar se ocorrer algum erro
set -e

source $(dirname $(dirname $(dirname $0)))"/utils/colors.sh"

echo_blue "Ambiente Ruby on Rails"

echo_blue 'Criando link de "unix_deploy"'
sudo ln -s ~/.unix_deploy ~/.unix_deploy

# Instal Ruby dependencies
echo_blue "Instalando dependencias..."
sudo apt-get update
sudo apt-get install -y git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev nodejs

# Install rbenv
echo_blue "Instalando rbenv..."
cd
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Install ruby-build
echo_blue "Instalando ruby-build..."
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby
echo_blue "Instalando ruby..."
read -p "Qual versao do ruby deseja instalar? (Ex: 2.2.2): " ruby_version
~/.rbenv/bin/rbenv install $ruby_version
~/.rbenv/bin/rbenv global $ruby_version

# Disable gem local docs
echo "gem: --no-document" > ~/.gemrc

# Install Bundler
echo_blue "Instalando bundler..."
/home/$USER/.rbenv/shims/gem install bundler

# Install Rails
echo_blue "Instalando rails..."
/home/$USER/.rbenv/shims/gem install rails

# Install Whenever
echo_blue "Instalando whenever..."
/home/$USER/.rbenv/shims/gem install whenever

~/.rbenv/bin/rbenv rehash

# Generate SSH keys
echo_blue "Criando ssh keys..."
ssh-keygen -t rsa

# Install Passenger and Nginx
echo_blue "Instalando passenger e nginx..."
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
# echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main' | sudo tee --append /etc/apt/sources.list.d/passenger.list
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jessie main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y nginx-extras passenger
# sudo /home/$USER/.rbenv/shims/passenger-install-nginx-module

passenger_root_old='# passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;'
passenger_root_new="passenger_root $(/usr/bin/passenger-config --root);"
sudo /usr/bin/replace "$passenger_root_old" "$passenger_root_new" -- /etc/nginx/nginx.conf

echo_blue 'Reiniciando nginx...'
sudo service nginx restart
echo ''
# echo_yellow 'Instalacao OK, agora abra => /etc/nginx/nginx.conf'
# echo_yellow 'Altere "passenger_root" e "passenger_ruby" para seus locais corretos'
# passenger_root $(/home/$USER/.rbenv/shims/passenger-config --root);
# passenger_root /home/$USER/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/passenger-5.0.20;
# passenger_ruby $(/home/$USER/.rbenv/shims/passenger-config about ruby-command | grep passenger_ruby);
# passenger_ruby /home/$USER/.rbenv/versions/2.2.2/bin/ruby;
echo_green "Ambiente Ruby on Rails instalado com sucesso!"
