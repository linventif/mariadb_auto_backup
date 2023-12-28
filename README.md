# Mariadb Backup

## Description

This is a simple script to backup a mariadb databases, compress it and send it to a remote server.

## Cron Job

Optionally, you can add a cron job to run the script periodically. For example, to run the script every 12 hours, add the following line to your crontab:

```bash
0 0/12 * * * /your/path/mariadb_backup.sh
```
