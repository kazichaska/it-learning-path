# PostgreSQL

> PostgreSQL ("Postgres") is the most popular open-source relational database: reliable, standards-compliant and extensible (JSONB, full-text search, PostGIS, pgvector). AWS offers it as **RDS for PostgreSQL** and **Aurora PostgreSQL**.

## Run PostgreSQL locally with Docker

From the repository root:
```bash
docker run -d --name pg \
  -e POSTGRES_USER=learner \
  -e POSTGRES_PASSWORD=devpass \
  -e POSTGRES_DB=shop \
  -p 5432:5432 \
  -v "$PWD/07-databases/sql":/docker-entrypoint-initdb.d:ro \
  -v pgdata:/var/lib/postgresql/data \
  postgres:17
```
- Files in `/docker-entrypoint-initdb.d` run **once**, in alphabetical order, the first time the data volume is created. That's why the SQL files are numbered `01-schema.sql`, `02-seed.sql`.
- `devpass` is a local-only practice password. Real passwords belong in a secrets manager.

Connect:
```bash
docker exec -it pg psql -U learner -d shop          # psql inside the container
psql "postgresql://learner:devpass@localhost:5432/shop"   # from your Mac (brew install libpq)
```
Start over with a fresh database: `docker rm -f pg && docker volume rm pgdata`, then run the command again.

## psql meta-commands

| Command | Does |
|---|---|
| `\l` | List databases |
| `\c shop` | Connect to a database |
| `\dt` | List tables |
| `\d orders` | Describe a table (columns, indexes, FKs) |
| `\du` | List roles/users |
| `\di` | List indexes |
| `\x` | Toggle expanded (vertical) output |
| `\timing` | Show query execution time |
| `\i file.sql` | Run a SQL file |
| `\e` | Edit the last query in your editor |
| `\q` | Quit |

## Users, roles and permissions

```sql
-- An application user that can read and write data but not change the schema
CREATE ROLE app_user WITH LOGIN PASSWORD 'change-me';
GRANT CONNECT ON DATABASE shop TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;

-- A read-only user for reporting
CREATE ROLE reporter WITH LOGIN PASSWORD 'change-me-too';
GRANT CONNECT ON DATABASE shop TO reporter;
GRANT USAGE ON SCHEMA public TO reporter;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reporter;
```
**Least privilege:** the app should never connect as the superuser/owner.

## Backups and restores

```bash
# Logical backup of one database (custom format: compressed, flexible restore)
docker exec pg pg_dump -U learner -d shop -Fc -f /tmp/shop.dump
docker cp pg:/tmp/shop.dump ./shop.dump

# Restore into a new database
docker exec pg createdb -U learner shop_restored
docker cp ./shop.dump pg:/tmp/shop.dump
docker exec pg pg_restore -U learner -d shop_restored /tmp/shop.dump

# Plain SQL dump (human-readable)
docker exec pg pg_dump -U learner -d shop > shop.sql
```
| Backup type | Tool | Notes |
|---|---|---|
| Logical | `pg_dump` / `pg_dumpall` | Portable, per-database; slow for huge DBs |
| Physical | `pg_basebackup`, WAL archiving | Whole cluster; enables point-in-time recovery |
| Managed | RDS automated backups + snapshots | Point-in-time restore to any second within the retention period |

🔁 **A backup you haven't restored is a hope, not a backup.** Practise restores.

## Configuration essentials

| Setting (postgresql.conf) | Meaning |
|---|---|
| `listen_addresses` | Which interfaces to listen on (`localhost` by default; `'*'` for all) |
| `port` | Default `5432` |
| `max_connections` | Each connection costs memory; use a pooler instead of raising this a lot |
| `shared_buffers` | Memory for caching data (often ~25% of RAM) |
| `log_min_duration_statement` | Log queries slower than N ms (e.g. `500`). Great for finding slow queries |

**`pg_hba.conf`** controls *who can connect from where, and how* (host-based authentication). "no pg_hba.conf entry for host…" means this file is rejecting the connection.

## Performance basics

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 1;    -- how is the query executed?
SELECT pid, state, wait_event, query FROM pg_stat_activity;     -- what's running right now?
SELECT pg_size_pretty(pg_database_size('shop'));                -- database size
SELECT pg_cancel_backend(<pid>);                                -- cancel a runaway query
```
- Index columns used in `WHERE`/`JOIN` on large tables
- `VACUUM` / `ANALYZE` (autovacuum does this automatically) keep tables and statistics healthy
- Too many connections? Use **PgBouncer** or **RDS Proxy**

## Troubleshooting connections

| Error | Cause |
|---|---|
| `Connection refused` | Postgres not running, wrong port, or `listen_addresses` is `localhost` only |
| `timeout expired` | Security group/firewall blocks 5432, or the DB is in a private subnet you can't reach |
| `password authentication failed` | Wrong user/password, or the user lacks `LOGIN` |
| `no pg_hba.conf entry for host` | `pg_hba.conf` doesn't allow your IP/user/database/SSL combination |
| `database "x" does not exist` | Wrong database name in the connection string |
| `too many connections` | Hit `max_connections`; add pooling, find connection leaks |
| `permission denied for table` | Missing `GRANT` for that role |

## PostgreSQL on AWS

| Option | Notes |
|---|---|
| **RDS for PostgreSQL** | Managed instances: backups, patching, Multi-AZ failover, read replicas |
| **Aurora PostgreSQL** | AWS-built storage layer: faster failover, up to 15 replicas; Aurora Serverless v2 scales automatically |
| Self-managed on EC2 | Full control, full responsibility. Rarely the right choice |

Best practices: private subnets only, security group allowing 5432 only from the app's security group, encryption at rest, credentials in **Secrets Manager** (with rotation), **Multi-AZ** for production, automated backups with enough retention, Performance Insights to find slow queries.

## 🏋️ Exercises
1. Start the container, connect with `psql`, and run `\dt` and `\d order_items`.
2. Create the `reporter` role above and connect as that user. Try an `INSERT`: what happens?
3. Back up `shop` with `pg_dump`, drop a table, and restore it.
4. Turn on `\timing` and compare `EXPLAIN ANALYZE` before and after creating an index on `customers(country)`. (With 8 rows Postgres may still choose a sequential scan. Why?)
