Quiz: Backup and Recovery in PostgreSQL
```
1. What is the difference between physical and logical backups in PostgreSQL?
   
  a) Physical backups back up the data files, while logical backups back up the database schema
and data in SQL format. ✅
  b) Logical backups only back up the database schema, while physical backups back up the entire database including data and WAL logs.
  c) There is no difference; both are the same.
  d) Physical backups are slower than logical backups.

2. Which PostgreSQL utility is used for logical backups?

a) pg_restore
b) pg_basebackup
c) pg_dump ✅
d) psql

3. Which option in pg_dump allows backing up a specific table from a database?

a) --table ✅
b) --exclude-table
c) --dump-table
d) --include-table

4. What is the purpose of pg_restore in PostgreSQL?

a) To restore global objects (roles, permissions, etc.).
b) To perform a physical backup of a PostgreSQL instance.
c) To restore data from a dump file created by pg_dump in custom format. ✅
d) To verify the integrity of a backup file.

5. If you want to exclude certain schemas while performing a pg_dump backup, which option would you use?

a) --exclude-schema ✅
b) --schema
c) --exclude-table
d) --no-schema

6. What is the main benefit of using pg_basebackup over pg_dump for backups?

a) It can perform logical backups of individual tables.
b) It is faster and allows for physical backups of the entire cluster, including WAL logs. ✅
c) It can only back up specific schemas.
d) It requires less disk space than logical backups.

7. What does the -Fc option in pg_dump signify?

a) It compresses the backup file.
b) It specifies the custom format for the backup. ✅
c) It includes the database schema in the backup.
d) It adds foreign keys during the backup process.

8. Which command is used to dump all global objects (roles, tablespaces) in PostgreSQL?

a) pg_dumpall -g ✅
b) pg_restore -g
c) pg_dump -g
d) pg_basebackup -g

9. Which PostgreSQL command would you use to restore a full database dump?

a) pg_dump
b) pg_basebackup
c) pg_restore -d ✅
d) psql -f

10. How do you perform a point-in-time recovery (PITR) in PostgreSQL?

a) Use pg_restore with a specific timestamp.
b) Restore from a full backup and then apply WAL archives. ✅
c) Use pg_basebackup and specify the --recover option.
d) Use pg_dump with --restore-time.
```
