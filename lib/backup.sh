#!/bin/bash


BACKUP_HOME=/home/updisadmin/db_backup
DB_NAME=la-producton


mkdir ${BACKUP_HOME}

datenow=`date +%Y%m%d`
date_before=`date -d "6 month ago" +%Y%m`

rm -f ${BACKUP_HOME}/${date_before}*

sudo su - postgres -c "pg_dump -Fc ${DB_NAME} > ${BACKUP_HOME}/datenow_backup.dump"

