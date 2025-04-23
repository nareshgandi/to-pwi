#!/bin/bash

# -----------------------------------------
# Restore a specific PostgreSQL database
# from a custom-format pg_dump backup file
# Usage:
#   ./restore_database.sh <database_name> [backup_date YYYY-MM-DD]
# -----------------------------------------

# === Configuration ===
BACKUP_DIR="/home/postgres/full_backups"
FILENAME_PREFIX="pgbkup"
PGHOST=""
PGUSER=""

# === Validate arguments ===
if [ -z "$1" ]; then
  echo "Usage: $0 <database_name> [backup_date YYYY-MM-DD]"
  exit 1
fi

DBNAME="$1"
RESTORE_DATE="${2:-$(date +%Y-%m-%d)}"

# === Construct the dump file path ===
DUMP_FILE="${BACKUP_DIR}/${FILENAME_PREFIX}_${DBNAME}_${RESTORE_DATE}.dump"

# === Check if dump file exists ===
if [ ! -f "$DUMP_FILE" ]; then
  echo "ERROR: Dump file not found: $DUMP_FILE"
  exit 1
fi

# === Construct PostgreSQL options ===
PG_OPTIONS=""
[ -n "$PGHOST" ] && PG_OPTIONS+=" -h $PGHOST"
[ -n "$PGUSER" ] && PG_OPTIONS+=" -U $PGUSER"

# === Drop the existing database ===
echo "Dropping database '$DBNAME' (if exists)..."
dropdb $PG_OPTIONS --if-exists "$DBNAME"

# === Recreate the database ===
echo "Creating database '$DBNAME'..."
createdb $PG_OPTIONS "$DBNAME"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to create database $DBNAME"
  exit 2
fi

# === Restore the backup ===
echo "Restoring database '$DBNAME' from $DUMP_FILE..."
pg_restore $PG_OPTIONS -d "$DBNAME" "$DUMP_FILE"

if [ $? -eq 0 ]; then
  echo "Database '$DBNAME' restored successfully from $DUMP_FILE"
else
  echo "Restore failed for $DBNAME"
  exit 3
fi

