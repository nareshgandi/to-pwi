# Installing PostgreSQL using DNF on RHEL-based Systems

https://github.com/user-attachments/assets/6e21f454-5d05-4dd1-8fe6-9f56422ea9ce

## Step 1: List Available PostgreSQL Modules
Check the available PostgreSQL versions.
```sh
dnf module list postgresql
```

## Step 2: Enable PostgreSQL 16 Module
Enable the PostgreSQL 16 module before installation.
```sh
dnf module enable postgresql:16
```

## Step 3: Disable PostgreSQL Module
Disable the current PostgreSQL module if needed.
```sh
dnf module disable postgresql
```

## Step 4: Install PostgreSQL Server
Install the PostgreSQL server package.
```sh
dnf install postgresql-server
```
## Step 5:Initialize the database cluster

```
postgresql-setup --initdb
```

## Step 6: Start the postgresql service

```
systemctl start postgresql.service
systemctl status postgresql.service
```
## Step 7: Login

```
su - postgres
psql
```

## Step 8: Reset PostgreSQL Module
Reset the PostgreSQL module configuration.
```sh
dnf module reset postgresql
```
