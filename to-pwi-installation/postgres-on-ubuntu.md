# Installing and Managing PostgreSQL on Debian/Ubuntu

https://github.com/user-attachments/assets/0b08d401-3d4c-4dcd-a54e-ea09d814acb7

## Step 1: Install PostgreSQL Common Package
Install the PostgreSQL common package, which includes scripts to manage PostgreSQL repositories.
```sh
sudo apt install -y postgresql-common
```

## Step 2: Initialize PostgreSQL Repository
Run the script to set up the official PostgreSQL repository.
```sh
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
```

## Step 3: Install PostgreSQL
Install the latest version of PostgreSQL, which also initializes the database and starts the service.
```sh
sudo apt -y install postgresql
```
## Step 4: Login and Check
```
su - postgres
psql
```

### Installation Details:
- Software is installed in `/usr/lib/postgresql/17/`
- Data directory is created at `/var/lib/postgresql/17/main`
- Configuration is derived from `/usr/share/postgresql-common/createcluster.conf`

# Custom location installation

## Step 1: List Existing Clusters
Check available PostgreSQL clusters and their status.
```sh
/usr/bin/pg_lsclusters
```

## Step 2: Stop and Remove the Default Cluster
If you want to remove the automatically created cluster:
```sh
/usr/bin/pg_dropcluster --stop 17 main
```

## Step 3: Create a New Cluster in a Custom Location
You can specify a custom directory for your PostgreSQL cluster.
```sh
/usr/bin/pg_createcluster 17 mydata -d /u01/pgsql/17
```

## Step 4: Start the New Cluster
```sh
/usr/bin/pg_ctlcluster 17 mydata start
```
Or using systemd:
```sh
systemctl start postgresql-17.service
```
## Step 5: Login and Check
```
su - postgres
psql
```
## Start/Stop PostgreSQL Using `pg_ctl`
If you prefer `pg_ctl` for cluster management:
```sh
/usr/lib/postgresql/17/bin/pg_ctl start "-D" "/u01/pgsql/17" "-o -c config_file=/etc/postgresql/17/mydata/postgresql.conf"

/usr/lib/postgresql/17/bin/pg_ctl stop "-D" "/u01/pgsql/17" "-o -c config_file=/etc/postgresql/17/mydata/postgresql.conf"
```

## PostgreSQL File Locations
- **PostgreSQL Tools**: `/usr/bin/` (e.g., `pg_lsclusters`, `pg_createcluster`, `pg_ctlcluster`)
- **PostgreSQL Binaries**: `/usr/lib/postgresql/17/bin/` (e.g., `pg_ctl`, `pg_dump`)
- **Data Files**: `/var/lib/postgresql/17/main`
- **Extensions**: `/usr/share/postgresql/17/`
- **Documentation**: `/usr/share/doc/postgresql-common`
- **Configuration Files**: `/etc/postgresql/`

## Common PostgreSQL Commands
- `/usr/bin/pg_lsclusters`: List all clusters with their status and configurations.
- `/usr/bin/pg_createcluster`: Wrapper for `initdb`, sets up the necessary configuration.
- `/usr/bin/pg_ctlcluster`: Wrapper for `pg_ctl`, used to start/stop clusters.
- `/usr/bin/pg_upgradecluster`: Upgrade a cluster to a newer major version.
- `/usr/bin/pg_dropcluster`: Remove a cluster and its configuration.
