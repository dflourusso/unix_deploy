# Configuração de servidor Debian 8 Jessie

---
## Instalação do plugin:
`bash <(curl -s https://raw.githubusercontent.com/dflourusso/unix_deploy/master/lib/configuration/install.sh)`

## Configurando um servidor:
`unix_deploy_setup_server`
	
Ao executar este comando o *plugin* irá solicitar um *host* para efetuar a configuração.

Configurações que o plugin irá fazer:

* Instalar o plugin no servidor
* Instalar: *sudo vim curl wget htop apt-transport-https ca-certificates*
* Adicionar memoria **swap**
* Adicionar **id_rsa.pub** no usuario root
* Instalar **mysql**
* Adicionar novo usuario
* Adicionar **id_rsa.pub** no usuario criado
* Instalar dependencias para **ruby on rails**: *zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev nodejs*
* Instalar **rbenv** e **ruby-build**
* Instalar **ruby**
* Instalar **bundler**
* Instalar **rails**
* Criar **ssh-keygen**
* Instalar **passenger** e **nginx**

<!--## Deploy de aplicação-->