#!/bin/bash

# Destination directory for backups
BACKUP_DIR="/root/backup/mariadb"
REMOTE_DIR="/home/linventif/backup"
MAX_BACKUP_DATES=30  # Maximum number of date folders to keep
REMOTE_IP="192.168.1.59"  # IP address of the remote server
USER="linventif"  # Remote server username

# Create a directory with the current date and time
CURRENT_DATE=$(date +"%Y-%m-%d-%H-%M")
CURRENT_DIR="$BACKUP_DIR/$CURRENT_DATE"
mkdir -p "$CURRENT_DIR"

# Get the list of databases
DATABASES=$(mysql -u root -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|sys)")

# Create a subdirectory for each database
for DB in $DATABASES; do
   DB_DIR="$CURRENT_DIR/$DB"
   mkdir -p "$DB_DIR"
   FILENAME="$DB-$(date +"%Y-%m-%d-%H-%M").sql"
   mysqldump -u root --databases "$DB" > "$DB_DIR/$FILENAME"
done

# Create a .tar.gz archive for all database folders
ARCHIVE_NAME="$CURRENT_DATE.tar.gz"
tar -czvf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$BACKUP_DIR" "$CURRENT_DATE"

# Transfer the archive to the remote server
scp "$BACKUP_DIR/$ARCHIVE_NAME" $USER@$REMOTE_IP:$REMOTE_DIR

# Delete the oldest date folders if the count exceeds MAX_BACKUP_DATES
DATE_DIRS=($(ls -1d "$BACKUP_DIR"/* | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}'))
DATE_COUNT=${#DATE_DIRS[@]}
if [ $DATE_COUNT -gt $MAX_BACKUP_DATES ]; then
   OLD_BACKUPS=$(($DATE_COUNT - $MAX_BACKUP_DATES))
   for ((i=0; i<$OLD_BACKUPS; i++)); do
       rm -rf "${DATE_DIRS[$i]}"
   done
fi