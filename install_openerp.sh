#!/usr/bin/env bash

VIRTUAL_ENV_PATH=$1
HTTP_PROXY=$2
OPENERP_DB_USER=$3
OPENERP_DB_HOST=$4
OPENERP_DB_PORT=$5

source "${VIRTUAL_ENV_PATH}/bin/activate"

echo "${VIRTUAL_ENV_PATH}"

echo '------Install External Python Egg------'
easy_install egenix-mx-base
pip install pydot feedparser psycopg2 psutil
echo 'complete......'

echo '------Installing Odoo------'
cd ${VIRTUAL_ENV_PATH}/odoo/
python setup.py build
python setup.py install
echo 'complete......'

echo '------Generate Odoo Config File------'
#TODO: --data-dir
mkdir $HOME/openerp-log
echo 'Please input openerp database User password:'
read OPENERP_USER_PASSWORD
openerp-server -s --addons-path=${VIRTUAL_ENV_PATH}/odoo/addons --logfile=$HOME/openerp-log/openerp.log --logrotate --db_user=${OPENERP_DB_USER} --db_password=${OPENERP_USER_PASSWORD} --db_host=${OPENERP_DB_HOST} --db_port=${OPENERP_DB_PORT} --stop-after-init
echo 'complete......'



