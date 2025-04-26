### Basic pgbackrest, lab01 is primary, lab02 in backup server

```
1. yum install pgbackrest [both machines]

2. set up passwordless connectivity for postgres user between both machines [both machines]

3. postgresql.conf [prod server]

archive_command = 'pgbackrest --stanza=lab01 archive-push %p'
archive_mode = on

4. Run in both machines [create required directories]

sudo mkdir -p -m 770 /var/log/pgbackrest
sudo chown postgres:postgres /var/log/pgbackrest

sudo mkdir -p /etc/pgbackrest
sudo mkdir -p /etc/pgbackrest/conf.d

sudo touch /etc/pgbackrest/pgbackrest.conf
sudo chmod 640 /etc/pgbackrest/pgbackrest.conf
sudo chown postgres:postgres /etc/pgbackrest/pgbackrest.conf

sudo mkdir -p /u01/backups/pgbackrest
sudo chown -R postgres:postgres /u01/backups/pgbackrest

5. Run in production server (/etc/pgbackrest/pgbackrest.conf)

[global]
repo1-host=lab02
repo1-host-user=postgres
log-level-console=info

[demo]
pg1-path=/u01/pgsql/17

6. Run in the backup server (/etc/pgbackrest/pgbackrest.conf)

[global]
repo1-path=/u01/backups/pgbackrest
log-level-console=info
repo1-retention-full=2
start-fast=y
stop-auto=y

[demo]
pg1-path=/u01/pgsql/17
pg1-host=lab01
pg1-port = 5432

sudo -u postgres pgbackrest --stanza=lab01 stanza-create
sudo -u postgres pgbackrest --stanza=lab01 check
sudo -u postgres pgbackrest --stanza=lab01 backup

* if required use --log-level-console=detail

7. To restore

sudo -u postgres pgbackrest --stanza=demo --log-level-console=info restore
```

### additional scenarios

```
a=# select pg_relation_filepath('emp');
 pg_relation_filepath
----------------------
 base/17440/17441
(1 row)

a=# \q
[postgres@lab02 17]$ cd base/17440
[postgres@lab02 17440]$ rm -rf 17441
[postgres@lab02 17440]$ psql
psql (17.4)
Type "help" for help.

postgres=# \c a
You are now connected to database "a" as user "postgres".
a=# select * from emp;
ERROR:  could not open file "base/17440

sudo -u postgres pgbackrest --stanza=demo restore --delta
```
### restore the database

```
create database a;
take backup
drop database a;

sudo -u postgres pgbackrest --stanza=demo --delta --db-include=a --type=immediate --target-action=promote restore
```

### pitr

```

-- do some activity
#Take the backup on the backup server:

sudo -u postgres pgbackrest --stanza=lab01 backup --type=incr

stop the database

sudo -u postgres pgbackrest --stanza=demo --delta
--target-timeline=current
--type=time "--target=2025-04-23 22:26:16" --target-action=promote restore

```

# Cloud

node 1
```
[root@lab02 pgbackrest]# cat /etc/pgbackrest/pgbackrest.conf
[cloud]
pg1-path=/u01/pgsql/17

[global]
repo1-retention-full=2
repo1-type=s3
repo1-path=/demo
repo1-s3-region=us-east-1
repo1-s3-endpoint=s3.us-east-1.amazonaws.com
repo1-s3-bucket=dmsmybucket
repo1-s3-key=
repo1-s3-key-secret=

# Force a checkpoint to start backup immediately.
start-fast=y
# Use delta restore.
delta=y

# Enable ZSTD compression.
compress-type=zst
compress-level=6

log-level-console=info
log-level-file=debug
[root@lab02 pgbackrest]#
```

Then

```
check
take backup
```
## set up standby

node 2
------

```
[root@lab01 ~]# cat /etc/pgbackrest/pgbackrest.conf
[cloud]
pg1-path=/u01/pgsql/17
recovery-option=primary_conninfo=host=lab02 user=postgres

[global]
repo1-retention-full=2
repo1-type=s3
repo1-path=/demo
repo1-s3-region=us-east-1
repo1-s3-endpoint=s3.us-east-1.amazonaws.com
repo1-s3-bucket=dmsmybucket
repo1-s3-key=
repo1-s3-key-secret=

# Force a checkpoint to start backup immediately.
start-fast=y
# Use delta restore.
delta=y

# Enable ZSTD compression.
compress-type=zst
compress-level=6

log-level-console=info
log-level-file=debug

[root@lab01 ~]#
```

### then run restore command
```
sudo -iu postgres pgbackrest --stanza=cloud --type=standby restore
```

