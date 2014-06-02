#!/usr/bin/env bash

PYTHON_ENV_ROOT=$1
VIRTUAL_ENV_NAME=$2
ODOO_FILE_PATH=$3

echo '------Create Python Virtual Enviroment------'
mkdir $HOME/${PYTHON_ENV_ROOT} && cd ~/${PYTHON_ENV_ROOT} && virtualenv ${VIRTUAL_ENV_NAME}
echo ''

echo '------Unzip Odoo File To Directory------'
tar -zxpf ${ODOO_FILE_PATH} -C $HOME/${PYTHON_ENV_ROOT}/${VIRTUAL_ENV_NAME}
echo ''

