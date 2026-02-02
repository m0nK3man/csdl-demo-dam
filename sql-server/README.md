# SQL Server WideWorldImporters Demo using Docker

This guide documents the exact steps to recreate a **SQL Server demo environment** using Docker and the **WideWorldImporters** sample database. It is suitable for DAM (Database Activity Monitoring) demos or general SQL Server testing.

---

## 1. Prerequisites

* Linux host (tested on Ubuntu)
* Docker Engine
* Docker Compose v2+
* Internet access to download the sample backup

Verify Docker:

```bash
docker version
docker compose version
```

---

## 2. Directory Structure

```text
DAM-demo/
└── sql-server/
    ├── docker-compose.yml
    └── WideWorldImporters-Full.bak
```

---

## 3. docker-compose.yml

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: wwi-sqlserver
    environment:
      ACCEPT_EULA: "Y"
      SA_PASSWORD: "YourStrong!Passw0rd"
      MSSQL_PID: "Developer"
      TZ: "UTC"
    ports:
      - "1433:1433"
    volumes:
      - mssql-data:/var/opt/mssql
    restart: unless-stopped

volumes:
  mssql-data:
```

Start the container:

```bash
docker compose up -d
```

Verify:

```bash
docker ps
```

---

## 4. Download WideWorldImporters Backup

From inside `sql-server/`:

```bash
curl -L -o WideWorldImporters-Full.bak \
  https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak
```

---

## 5. Copy Backup into Container

Create backup directory inside SQL Server container:

```bash
docker exec -it wwi-sqlserver mkdir -p /var/opt/mssql/backup
```

Copy the backup file:

```bash
docker cp WideWorldImporters-Full.bak \
  wwi-sqlserver:/var/opt/mssql/backup
```

---

## 6. SQLCMD Notes (Important)

* SQL Server 2022 images include **sqlcmd v18**
* ODBC Driver 18 **enforces TLS by default**
* Because the container uses a self-signed certificate, you must use:

```
-C   # trust server certificate
```

Without `-C`, you will see:

> SSL Provider: certificate verify failed: self-signed certificate

---

## 7. Inspect Backup Logical File Names

```bash
docker exec -it wwi-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'YourStrong!Passw0rd' \
  -C \
  -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/WideWorldImporters-Full.bak'"
```

Expected logical names:

* `WWI_Primary`
* `WWI_UserData`
* `WWI_Log`
* `WWI_InMemory_Data_1`

---

## 8. Restore the Database

```bash
docker exec -it wwi-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'YourStrong!Passw0rd' \
  -C \
  -Q "
RESTORE DATABASE WideWorldImporters
FROM DISK = '/var/opt/mssql/backup/WideWorldImporters-Full.bak'
WITH
  MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporters.mdf',
  MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_userdata.ndf',
  MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImporters.ldf',
  MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1'
"
```

The database will be automatically upgraded to the SQL Server 2022 format during restore.

---

## 9. Verify Database Status

```bash
docker exec -it wwi-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P 'YourStrong!Passw0rd' \
  -C \
  -Q "SELECT name, state_desc FROM sys.databases WHERE name = 'WideWorldImporters';"
```

Expected output:

```text
WideWorldImporters | ONLINE
```

---

## 10. Connection Details (for DAM / Tools)

* **Host:** Docker host IP or `localhost`
* **Port:** 14330
* **Username:** SA
* **Password:** YourStrong!Passw0rd

## 11. Notes

* This setup is **not production-hardened**
* TLS is trusted, not validated
* Passwords are hardcoded for demo simplicity

---

**End of Guide**
