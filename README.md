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
* Adicionar memoria *swap*
* Adicionar *id_rsa.pub* no usuario root
* Instalar **mysql*
* Adicionar novo usuario
* Adicionar *id_rsa.pub* no usuario criado
* Instalar dependencias para *ruby on rails*: *zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev nodejs*
* Instalar *rbenv* e *ruby-build*
* Instalar *ruby*
* Instalar *bundler*
* Instalar *rails*
* Criar *ssh-keygen*
* Instalar *passenger* e *nginx*

## Deploy de aplicação

Entre na pasta de seu projeto: `cd my_user/my_rails_project`

###Digite: 

`/opt/.unix_deploy/bin/unix_deploy_start -i`

`/opt/.unix_deploy/bin/unix_deploy_start -n`

###Opções disponíveis
	
	[-h] => Ajuda
	[-i] => Iniciar plugin no projeto
	[-g] => Executar o deploy sem incrementar versão do código fonte e sem efetuar push
	[-n] => Criar nova aplicação para realizar o deploy
> Se chamado sem parâmetro irá executar o **deploy** nos servidores e aplicações configuradas dentro da pasta **.deploy** do projeto.

Ações que o deploy irá fazer:

* Merge do git do *develop* para o *master*, incrementar versão e push para o servidor
* Clonar/Atualizar repositório no servidor remoto de acordo com as configurações da pasta *.deploy*
* Configurar *nginx* e variáveis de ambiente
* Instalar *gems* e outras dependências, executar migrações, compilar assets
* Reiniciar aplicação
