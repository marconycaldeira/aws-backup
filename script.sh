#!/bin/bash

NOW=$(date +"%Y-%m-%d")

BACKUP_DIR="/home/backup"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PASSWORD="pass"
DATABASE_NAME="db"

AMAZON_S3_BUCKET="s3://bucket-name"
AMAZON_S3_BIN="/usr/bin/aws"

FOLDERS_TO_BACKUP=("/var/www/your-site")

#################################################################

mkdir -p ${BACKUP_DIR}

backup_mysql(){
         echo  "init database dump" >> /home/backup/log.log
         mysqldump -h ${MYSQL_HOST} \
           -P ${MYSQL_PORT} \
           -u ${MYSQL_USER} \
           -p${MYSQL_PASSWORD} ${DATABASE_NAME} | gzip > ${BACKUP_DIR}/${DATABASE_NAME}-${NOW}.sql.gz
         echo  "end database dump"  >> /home/backup/log.log
}

# backup any folders?
backup_files(){
        echo  "init compress files"  >> /home/backup/log.log
        tar -cvzf ${BACKUP_DIR}/backup-files-${NOW}.tar.gz ${FOLDERS_TO_BACKUP[@]}
        echo  "end compress files"  >> /home/backup/log.log
}

upload_db_to_s3(){
        echo  "upload database to aws"  >> /home/backup/log.log
        ${AMAZON_S3_BIN} s3 cp ${BACKUP_DIR}/${DATABASE_NAME}-${NOW}.sql.gz ${AMAZON_S3_BUCKET}
        echo  "end database to aws"  >> /home/backup/log.log
}

upload_files_to_s3(){
        echo  "upload files to aws"  >> /home/backup/log.log
        ${AMAZON_S3_BIN} s3 cp ${BACKUP_DIR}/backup-files-${NOW}.tar.gz ${AMAZON_S3_BUCKET}
        echo  "end upload files to aws"  >> /home/backup/log.log
}

remove_files(){
        echo  "upload database to aws"  >> /home/backup/log.log
        rm ${BACKUP_DIR}/backup-files-${NOW}.tar.gz  ${BACKUP_DIR}/${DATABASE_NAME}-${NOW}.sql.gz
        echo  "end upload files to aws"  >> /home/backup/log.log
}

backup_mysql
backup_files
upload_db_to_s3
upload_files_to_s3
