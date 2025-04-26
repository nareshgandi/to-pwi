1. Full backup
```
rsync -a --delete /u01/pgsql/17 /u01/backups/
```

2. Edit postgresql.conf

3. Take incremental backup

```
mkdir -p /u01/incr
rsync -a --delete --link-dest=/u01/backups/17 /u01/pgsql/17/ /u01/incr
```

Verify
```
ls -li /u01/backups/17/PG_VERSION
ls -li /u01/incr/PG_VERSION

### inode number should match

ls -li /u01/backups/17/postgresql.conf
ls -li /u01/incr/postgresql.conf

### inode number should be different
```
