#!/bin/bash

# PostgreSQL Full Cluster Backup Script (Date only in filenames)

REQUIRED_USER="postgres"
BACKUP_DIR="/home/postgres/full_backups"
FILENAME_PREFIX="pgbkup"
RETENTION_DAYS=7
PGHOST=""
PGUSER=""
NOW=$(date +%Y-%m-%d)  # Date only (no timestamp)

if [ "$(whoami)" != "$REQUIRED_USER" ]; then
  echo "ERROR: This script must be run as user: $REQUIRED_USER"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

echo ">>> PostgreSQL full cluster backup started at $(date)"

PG_OPTIONS=""
[ -n "$PGHOST" ] && PG_OPTIONS+=" -h $PGHOST"
[ -n "$PGUSER" ] && PG_OPTIONS+=" -U $PGUSER"

# Backup global objects (roles, tablespaces, etc)
GLOBAL_DUMP_FILE="${BACKUP_DIR}/${FILENAME_PREFIX}_globals_${NOW}.sql"
echo "Dumping global objects to $GLOBAL_DUMP_FILE"
pg_dumpall $PG_OPTIONS -g > "$GLOBAL_DUMP_FILE"
[ $? -ne 0 ] && echo "ERROR: Failed to dump globals" && exit 2

# Get list of databases
DATABASES=$(psql $PG_OPTIONS -Atc "SELECT datname FROM pg_database WHERE datistemplate = false AND datallowconn = true")
[ $? -ne 0 ] && echo "ERROR: Could not retrieve list of databases" && exit 3

# Dump each database
for DB in $DATABASES; do
  DB_DUMP_FILE="${BACKUP_DIR}/${FILENAME_PREFIX}_${DB}_${NOW}.dump"
  echo "Dumping database: $DB -> $DB_DUMP_FILE"
  pg_dump $PG_OPTIONS -Fc "$DB" > "$DB_DUMP_FILE"
  [ $? -ne 0 ] && echo "ERROR: Failed to dump $DB" && exit 4
done

# Cleanup old backups
if [ "$RETENTION_DAYS" -gt 0 ]; then
  echo "Cleaning backups older than $RETENTION_DAYS days..."
  find "$BACKUP_DIR" -type f -name "${FILENAME_PREFIX}_*" -mtime +$RETENTION_DAYS -exec rm -f {} \;
fi

echo ">>> Backup completed successfully at $(date)"
exit 0

