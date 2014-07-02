#!/bin/bash

datenow=`date +%Y%m%d`
date_before=`date -d "6 month ago" +%Y%m`
cd /home/updisadmin/db_backup/

rm -f ${date_before}*

#service postgresql stop
#tar -cvpzf ${datenow}_backup.tar.gz /var/lib/postgresql/9.1
#service postgresql start

sudo su - postgres -c "pg_dump -Fc develop  > /home/updisadmin/db_backup/test_backup.gz"

#mount -t nfs 10.100.100.172:/home/updisadmin/db_remote_backup /home/updisadmin/remote_temp
#cp ${datenow}_backup.tar.gz /home/updisadmin/remote_temp/
#umount /home/updisadmin/remote_temp

mount -o username=,password= //10./db_backup_file /home/updisadmin/remote_temp
cp ${datenow}_backup.tar.gz /home/updisadmin/remote_temp/
umount /home/updisadmin/remote_temp
