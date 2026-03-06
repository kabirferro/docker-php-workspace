# PHP Workspace

A local development environment powered by Docker Compose, including Apache, PHP 7.4, PHP 8.2, MySQL 8, phpMyAdmin and Redis.

## Stack

| Service     | Image / Version           | Default port  |
|-------------|---------------------------|---------------|
| Apache      | custom build              | 80 / 443      |
| PHP 7.4     | custom build (FPM)        | —             |
| PHP 8.2     | custom build (FPM)        | —             |
| MySQL       | mysql:8.0                 | 3306          |
| phpMyAdmin  | phpmyadmin:latest         | 8080          |
| Redis       | redis:7-alpine            | 6379          |

---

## Project structure

```
workspace/
├── docker-compose.yml
├── .env                  ← local config (not versioned)
├── .env.example          ← template to copy
├── conf/
│   ├── mysql/my.cnf      ← MySQL configuration
│   ├── php/php74.ini     ← php.ini for PHP 7.4
│   └── php/php82.ini     ← php.ini for PHP 8.2
├── src/
│   ├── Dockerfile.apache
│   ├── Dockerfile.php74
│   ├── Dockerfile.php82
│   ├── generate-vhosts.sh
│   └── init-database.sql
└── README.md
```

---

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with WSL2 backend enabled
- Windows 10/11 or Linux

---

## Setup

### 1. Clone the repository

```powershell
git clone https://github.com/tuousername/php-workspace.git
cd php-workspace
```

### 2. Configure the environment

```powershell
cp .env.example .env
```

Open `.env` and set your paths and credentials:

```dotenv
# Path to your web projects folder
WEB_DIR=C:/path/to/your/web

# Path where MySQL data will be stored (created automatically)
DB_DIR=./data

# Path to the vhosts folder (created automatically)
VHOSTS_DIR=./vhosts
```

### 3. Start the containers

```powershell
docker compose up -d
```

On the first run Docker will build the PHP and Apache images — this may take a few minutes.

---

## WSL2 setup (recommended for performance)

If your web files live inside WSL2, set `WEB_DIR` to the WSL path:

```dotenv
WEB_DIR=//wsl.localhost/Ubuntu-24.04/home/youruser/web
```

This bypasses the NTFS→9P bridge and provides native ext4 performance for PHP (10-50x faster on large projects).

To move your files into WSL2:
```bash
# From a WSL2 terminal
cp -r /mnt/c/path/to/web ~/web
```

---

## Virtual hosts

Apache vhost files go in the folder pointed to by `VHOSTS_DIR`. They are loaded automatically when the Apache container starts.

Example vhost (`myproject.local.conf`):

```apache
<VirtualHost *:80>
    ServerName myproject.local
    DocumentRoot /var/www/html/myproject/public

    <Directory /var/www/html/myproject/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

Add the domain to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1  myproject.local
```

---

## Useful commands

```powershell
# Start
docker compose up -d

# Stop
docker compose down

# Live logs
docker compose logs -f

# Open a shell inside a container
docker exec -it php82 bash
docker exec -it mysql80 bash

# Dump all databases
docker exec mysql80 mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > backup.sql

# Import a dump
docker exec -i mysql80 mysql -u root -p${MYSQL_ROOT_PASSWORD} < backup.sql
```

---

## Default credentials

Defined in `.env`, example values from `.env.example`:

| Service    | Variable            | Example value         |
|------------|---------------------|-----------------------|
| MySQL root | MYSQL_ROOT_PASSWORD | your-root-password    |
| MySQL user | MYSQL_USER          | your-mysql-user       |
| MySQL pass | MYSQL_PASSWORD      | your-mysql-password   |
| phpMyAdmin | —                   | http://localhost:8080 |

---

## License

MIT
