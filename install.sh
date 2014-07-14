#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"

LINUX_USER=cysnake4713

#HTTP_PROXY=192.168.0.101:8087

OPENERP_DB_USER=openerp_updis
OPENERP_DB_HOST=localhost
OPENERP_DB_PORT=5433

PYTHON_ENV_ROOT=$HOME/pythonenv
PYTHON_ENV_NAME=la-erp

SEPERATE_PIP_INSTALL='pydot feedparser psycopg2 psutil geoip pypdf egenix-mx-base'

ODOO_SERVICE_NAME=odooserver
ODOO_ORIGIN_PATH=/home/cysnake4713/githome/odoo
#ODOO_ORIGIN_PATH=${CURRENT_DIR}/odoo
ODOO_ROOT=${PYTHON_ENV_ROOT}/${PYTHON_ENV_NAME}/odoo
ODOO_DAEMON=${ODOO_ROOT}/openerp-server
ODOO_CONFIG_DIR=/etc/openerp
ODOO_CONFIG=${ODOO_CONFIG_DIR}/openerp-server.conf
ODOO_LOGFILE_DIR=/var/log/openerp
ODOO_LOGFILE=${ODOO_LOGFILE_DIR}/openerp-server.log


PYTHON_ENV_PATH=${PYTHON_ENV_ROOT}/${PYTHON_ENV_NAME}

# Install Dependence
echo '------Installing Dependence------'
sudo apt-get -y -qq install libgeoip-dev libpq-dev python-dev libldap2-dev libsasl2-dev libssl-dev libxml2 libxml2-dev libxslt1-dev python-virtualenv git libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python-tk
echo "------complete------"
echo ''

# Install Postgresql
echo "Current Settings:"
printf "\tOPENERP_DB_USER: ${OPENERP_DB_USER}\n"
printf "\tOPENERP_DB_HOST: ${OPENERP_DB_HOST}\n"
printf "\tOPENERP_DB_PORT: ${OPENERP_DB_PORT}\n"

read -p "Install Postgresql?:y/n " result
if [ ${result} == 'y' ]; then
    echo '------Installing Postgresql------'
    sudo apt-get -y -qq install postgresql
    echo '------Config Postgres User------'
    sudo su - postgres -c "createuser --createdb --superuser --no-createrole --pwprompt ${OPENERP_DB_USER}"
    echo '------Postgresql Install complete......'
fi
echo ''

# Install VirtualEnv
echo "PYTHON_ENV_ROOT: ${PYTHON_ENV_ROOT}"
echo "VIRTUAL_ENV_NAME: ${PYTHON_ENV_NAME}"

read -p "Create virtualenv?:y/n " result
if [ ${result} == 'y' ]; then
    echo '------Create Python Virtual Enviroment------'
    # if virtual env root directory is not exist:
    if [ ! -d "${PYTHON_ENV_ROOT}" ]; then
        mkdir ${PYTHON_ENV_ROOT}
    fi
    # if virtual env is exist
    if [ -d "${PYTHON_ENV_ROOT}/${PYTHON_ENV_NAME}" ]; then
        read -p "virtualenv exists, recreate?:y/n" result
        if [ ${result} == 'y' ]; then
            echo "------removing virtualenv------"
            rm -rf ${PYTHON_ENV_ROOT}/${PYTHON_ENV_NAME}
            echo "------creating virtualenv------"
            cd ${PYTHON_ENV_ROOT} && virtualenv ${PYTHON_ENV_NAME}
        fi
    else
        echo "------creating virtualenv------"
        cd ${PYTHON_ENV_ROOT} && virtualenv ${PYTHON_ENV_NAME}
    fi
    echo '------Virtualenv Install complete......'
fi
echo ''

# Copy Odoo File
echo "ODOO_ORIGIN_PATH: ${ODOO_ORIGIN_PATH}"
echo "Target ODOO_ROOT: ${ODOO_ROOT}"

read -p "copy odoo code?:y/n " result
if [ ${result} == 'y' ]; then
    if [ -d "${ODOO_ROOT}" ]; then
        #TODO: have bug here!
        read -p "odoo code exists, recreate?:y/n" result
        if [ ${result} == 'y' ]; then
            echo "------removing odoo code------"
            rm -rf ${ODOO_ROOT}
            echo "------creating odoo code------"
            ( cd ${ODOO_ORIGIN_PATH} && tar -c . ) | ( cd ${ODOO_ROOT} && tar -x -p )
        fi
    else
        echo "------creating odoo code------"
        mkdir ${ODOO_ROOT} && ( cd ${ODOO_ORIGIN_PATH} && tar -c . ) | ( cd ${ODOO_ROOT} && tar -x -p )
    fi
fi
echo '------odoo code copy complete......'
echo ''

# GET odoo special version
read -p "want specialize odoo version?:y/n " result
if [ ${result} == 'y' ]; then
    echo "------Current Odoo Git Version:------"
    cd ${ODOO_ROOT}
    git fetch origin --tags
    echo "------Show Current Tags------"
    git tag
    read -p "Which version you want to use:" result
    git checkout ${result}
    echo "------complete------"
fi
echo ''

# Install Odoo
echo "------Installing Odoo------"
echo "PYTHON_ENV_PATH: ${PYTHON_ENV_PATH}"

if [ -e "${PYTHON_ENV_PATH}/bin/activate" ]; then
    source "${PYTHON_ENV_PATH}/bin/activate"
else
    echo "Virtual Env Not Exist!! exit"
    exit 1
fi

read -p "want install or reinstall odoo?:y/n " result
if [ ${result} == 'y' ]; then
    # install dependence
    echo '------Install External Python Egg------'
    pip install ${SEPERATE_PIP_INSTALL}
    echo 'complete......'
    # install odoo
    echo '------Installing Odoo------'
    cd ${ODOO_ROOT}
    python setup.py build
    python setup.py install
    echo 'complete......'
fi
echo ''

# generate odoo config file
read -p "want create or recreate odoo config file ${ODOO_CONFIG}?:y/n " result
if [ ${result} == 'y' ]; then
    echo '------Generate Odoo Config File------'
    #TODO: --data-dir
    read -p "Please input openerp database User password:" result
    openerp-server -s --addons-path=${PYTHON_ENV_PATH}/odoo/addons --logrotate --db_user=${OPENERP_DB_USER} --db_password=${result} --db_host=${OPENERP_DB_HOST} --db_port=${OPENERP_DB_PORT} --stop-after-init
    if [ ! -d '${ODOO_CONFIG_DIR}' ]; then
        sudo mkdir ${ODOO_CONFIG_DIR}
        sudo chown ${LINUX_USER} ${ODOO_CONFIG_DIR}
        sudo chgrp ${LINUX_USER} ${ODOO_CONFIG_DIR}
    fi
    sudo cp -f ${HOME}/.openerp_serverrc ${ODOO_CONFIG}
    sudo chown ${LINUX_USER} ${ODOO_CONFIG}
    sudo chgrp ${LINUX_USER} ${ODOO_CONFIG}
    if [ ! -d '${ODOO_LOGFILE_DIR}' ]; then
        sudo mkdir ${ODOO_LOGFILE_DIR}
        sudo chown ${LINUX_USER} ${ODOO_LOGFILE_DIR}
        sudo chgrp ${LINUX_USER} ${ODOO_LOGFILE_DIR}
    fi
    echo 'complete......'
fi
echo ''

# Create Odoo Service
echo "LINUX_USER: ${LINUX_USER}"
echo "ODOO_SERVICE_NAME: ${ODOO_SERVICE_NAME}"
echo "ODOO_DAEMON: ${ODOO_DAEMON}"
echo "ODOO_CONFIG: ${ODOO_CONFIG}"
echo "ODOO_LOGFILE: ${ODOO_LOGFILE}"
read -p "want create or recreate odoo service?:y/n " result
if [ ${result} == 'y' ]; then
    sudo sed \
    -e "s@%{DAEMON}@${ODOO_DAEMON}@g" \
    -e "s@%{CONFIG}@${ODOO_CONFIG}@g" \
    -e "s@%{LOGFILE}@${ODOO_LOGFILE}@g" \
    -e "s@%{USER}@${LINUX_USER}@g" \
    -e "s@%{PYTHON_ENV_PATH}@${PYTHON_ENV_PATH}/bin/activate@g" \
    -e "s@%{SERVICE_NAME}@${ODOO_SERVICE_NAME}@g" \
    ${CURRENT_DIR}/lib/openerp | sudo tee /etc/init.d/${ODOO_SERVICE_NAME} > /dev/null
    sudo chmod +x /etc/init.d/${ODOO_SERVICE_NAME}
#    sudo update-rc.d ${ODOO_SERVICE_NAME} defaults
    echo 'complete......'
fi

#TODO: Install whkhtmltopdf
#TODO: Test Server



