# Installing PostgreSQL 17 using Docker on Ubuntu

https://github.com/user-attachments/assets/d6d95abc-4d61-4de0-a612-24ab2009197d

## Step 1: Update System Packages
```sh
sudo apt update
```

## Step 2: Install Docker
```sh
sudo apt install -y docker.io
```

## Step 3: Start and Enable Docker
```sh
sudo systemctl start docker
sudo systemctl enable docker
```

## Step 4: Verify Docker Installation
```sh
docker --version
```

## Step 5: Pull PostgreSQL 17 Docker Image
```sh
docker pull postgres:17
```

## Step 6: Run PostgreSQL 17 Container
```sh
docker run -d --name pg17 -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:17
```

## Step 7: Verify Running Containers
```sh
docker ps
```

## Step 8: Connect to PostgreSQL
```sh
docker exec -it pg17 psql -U postgres -d postgres
```

## Step 9: View PostgreSQL Logs
```sh
docker logs pg17
```

## Step 10: Restart PostgreSQL Container
```sh
docker restart pg17
```

## Step 11: Stop PostgreSQL Container
```sh
docker stop pg17
