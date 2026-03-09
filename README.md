# Docker PHP Workspace

A local development environment powered by Docker Compose, running on **Windows with Docker Desktop**. Includes Apache, PHP 7.4, PHP 8.2, MySQL 8, phpMyAdmin and Redis.

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
php-workspace/          ← versioned (this repository)
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
├── mysql-data/           ← MySQL data files (default, contents not versioned)
├── vhosts/               ← Apache vhost configs & SSL certs (default, contents not versioned)
├── web/                  ← web projects root (default, contents not versioned)
└── README.md
```

> **Default paths**: `mysql-data/`, `vhosts/` and `web/` are included in the repository as empty
> placeholder folders. Docker Compose mounts them by default via the `DB_DIR`, `VHOSTS_DIR` and
> `WEB_DIR` variables (set to `./mysql-data`, `./vhosts` and `./web` in `.env.example`).
> You can override any of them in your `.env` with an absolute path if you prefer to keep data
> outside the project directory.

---

## Requirements

- Windows 10/11
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

## Setup

### 1. Clone the repository

```powershell
git clone https://github.com/tuousername/php-workspace.git
cd php-workspace
```

### 2. Configure the environment

```powershell
Copy-Item .env.example .env
```

Open `.env` and set your credentials. The three data paths already default to folders inside
this repository (`./mysql-data`, `./vhosts`, `./web`) — you can leave them as-is or point them
to any absolute path if you prefer to keep data elsewhere:

```dotenv
# Default: uses the mysql-data/ folder inside the project
DB_DIR=./mysql-data

# Default: uses the vhosts/ folder inside the project
VHOSTS_DIR=./vhosts

# Default: uses the web/ folder inside the project
WEB_DIR=./web

# MySQL credentials
MYSQL_ROOT_PASSWORD=your-root-password
MYSQL_USER=your-mysql-user
MYSQL_PASSWORD=your-mysql-password
```

Use forward slashes (`/`) for both relative and absolute Windows paths — Docker Desktop handles
the conversion automatically.

### 3. Start the containers

```powershell
docker compose up -d
```

On the first run Docker will build the PHP and Apache images — this may take a few minutes.

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
