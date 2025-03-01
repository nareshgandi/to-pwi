# Uninstall PostgreSQL on CentOS and Ubuntu

## Uninstall PostgreSQL on CentOS

### Step 1: Stop PostgreSQL Service
```sh
sudo systemctl stop postgresql-17
```

### Step 2: Remove PostgreSQL Packages
```sh
sudo dnf remove -y postgresql*
sudo dnf remove pgdg-redhat-repo -y
```

### Step 3: Remove PostgreSQL Data Directory
```sh
sudo rm -rf /var/lib/pgsql
```

### Step 4: Remove PostgreSQL User (Optional)
```sh
sudo userdel -r postgres
```

## Uninstall PostgreSQL on Ubuntu

### Step 1: Stop PostgreSQL Service
```sh
sudo systemctl stop postgresql-17.service
```

### Step 2: Remove PostgreSQL Packages
```sh
sudo apt remove -y postgresql postgresql-client postgresql-contrib
```

### Step 3: Remove PostgreSQL Data Directory
```sh
sudo rm -rf /var/lib/postgresql
sudo rm -rf /etc/postgresql
```

### Step 4: Remove PostgreSQL User (Optional)
```sh
sudo deluser postgres
```

### Step 5: Clean Up Unused Dependencies
```sh
sudo apt autoremove -y
