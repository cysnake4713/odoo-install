#!/usr/bin/env bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
LINUX_USER=cysnake4713
OPENERP_DB_USER=openerpuser
OPENERP_DB_HOST=localhost
OPENERP_DB_PORT=5432
VIRTUAL_ENV_NAME=openerp8
HTTP_PROXY=192.168.0.101:8087
ODOO_FILE_PATH=${DIR}/odoo.tar.gz

PYTHON_ENV_ROOT=pythonenv


echo '------Installing Dependence------'
apt-get install postgresql libpq-dev python-dev libldap2-dev libsasl2-dev libssl-dev libxml2 libxml2-dev libxslt1-#dev python-virtualenv
echo 'complete......'

echo '------Config Postgres User------'
su - postgres -c "createuser --createdb --superuser --no-createrole --pwprompt ${OPENERP_DB_USER}"
echo 'complete......'

su - ${LINUX_USER} -s "${DIR}/create_env.sh" ${PYTHON_ENV_ROOT} ${VIRTUAL_ENV_NAME} ${ODOO_FILE_PATH}

su - ${LINUX_USER} -s "${DIR}/install_openerp.sh" $HOME/${PYTHON_ENV_ROOT}/${VIRTUAL_ENV_NAME} ${HTTP_PROXY} ${OPENERP_DB_USER} ${OPENERP_DB_HOST} ${OPENERP_DB_PORT}

