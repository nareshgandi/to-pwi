# Installing PostgreSQL on RHEL-based Systems

## Step 1: Add PostgreSQL Repository
Install the PostgreSQL Global Development Group (PGDG) repository.
```sh
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

## Step 2: Disable Default PostgreSQL Module
Ensure the default PostgreSQL module is disabled to avoid conflicts.
```sh
dnf -qy module disable postgresql
```

## Step 3: Install PostgreSQL 16 Server
This command installs the PostgreSQL 16 server package and automatically creates a `postgres` user at the OS level.
```sh
dnf install -y postgresql17-server
```

## Step 4: Initialize the Database
Run the following command to initialize the PostgreSQL database.
```sh
/usr/pgsql-16/bin/postgresql-17-setup initdb
```

## Step 5: Enable and Start PostgreSQL Service
Enable PostgreSQL to start on boot and then start the service.
```sh
systemctl enable postgresql-17
systemctl start postgresql-17
```

## Custom Data Directory Configuration
If you need to set up a custom data directory:
1. Stop the existing postgres, if any
```
systemctl stop postgresql-16
```
1. Edit the `PGDATA` variable in the PostgreSQL service file.
```sh
nano /lib/systemd/system/postgresql-16.service
```
2. Reload the systemd daemon to apply changes.
```sh
systemctl daemon-reload
```
