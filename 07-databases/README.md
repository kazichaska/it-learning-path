# 07 · Databases

> **Goal:** Query data confidently with SQL, design sensible schemas, and run PostgreSQL (locally and on AWS RDS): connections, users, backups and performance basics.

Almost every application has a database behind it, and many production incidents involve one (slow queries, full disks, connection limits, failed migrations).

## 📚 Contents

| Topic | Where |
|---|---|
| Database concepts & data modeling | This page ⬇️ |
| SQL tutorial (SELECT → JOINs → window functions) | [`sql/README.md`](sql/README.md) |
| Practice schema & data | [`sql/01-schema.sql`](sql/01-schema.sql), [`sql/02-seed.sql`](sql/02-seed.sql) |
| SQL exercises with answers | [`sql/exercises.md`](sql/exercises.md) |
| PostgreSQL: run it, administer it, back it up | [`postgresql/README.md`](postgresql/README.md) |

## 1. Types of databases

| Type | Data model | Examples | Use when… |
|---|---|---|---|
| **Relational (SQL)** | Tables with rows/columns and relationships | PostgreSQL, MySQL, SQL Server, Aurora | Structured data, transactions, complex queries. **The default choice** |
| **Key-value** | Key → value | Redis/Valkey, DynamoDB | Caching, sessions, simple fast lookups at huge scale |
| **Document** | JSON-like documents | MongoDB, DynamoDB, Firestore | Flexible/nested data that varies per record |
| **Wide-column** | Rows with dynamic columns, partitioned | Cassandra, Bigtable | Massive write-heavy workloads |
| **Graph** | Nodes and edges | Neo4j, Neptune | Relationships are the point (social networks, fraud) |
| **Time-series** | Timestamped measurements | Prometheus, InfluxDB, TimescaleDB | Metrics, IoT |
| **Search** | Inverted indexes | OpenSearch/Elasticsearch | Full-text search, log analytics |

## 2. Relational concepts

| Term | Meaning |
|---|---|
| **Table** | A set of rows with the same columns (e.g. `customers`) |
| **Primary key (PK)** | Uniquely identifies each row (`customer_id`) |
| **Foreign key (FK)** | A column referencing another table's PK (`orders.customer_id → customers.customer_id`); enforces valid relationships |
| **Constraint** | Rules the DB enforces: `NOT NULL`, `UNIQUE`, `CHECK (price >= 0)` |
| **Index** | A lookup structure that speeds up reads on a column (at a small cost to writes and storage) |
| **Transaction** | A group of statements that succeed or fail **together** |
| **Schema** | The structure (tables, columns, types); in PostgreSQL also a namespace within a database |

### ACID: why relational databases are trusted with money
- **Atomicity:** all of a transaction happens, or none of it
- **Consistency:** constraints are always respected
- **Isolation:** concurrent transactions don't see each other's half-finished work
- **Durability:** once committed, data survives crashes (write-ahead log)

```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;      -- or ROLLBACK; to undo both
```

## 3. Data modeling & normalization

**Normalization** = organize data to avoid duplication and inconsistency.

❌ **Unnormalized:** customer details repeated on every order row
| order_id | customer_name | customer_email | product | price |
|---|---|---|---|---|
| 1 | Alice | alice@example.com | Keyboard | 49.00 |
| 2 | Alice | alice@exmaple.com | Mouse | 19.00 |

Problems: duplicated data, typos (`exmaple`), updating Alice's email means changing many rows.

✅ **Normalized:** separate tables linked by keys (this is exactly the [practice schema](sql/01-schema.sql)):
```
customers (customer_id PK, name, email UNIQUE, country)
     │ 1
     │
     │ many
orders (order_id PK, customer_id FK, order_date, status)
     │ 1
     │
     │ many
order_items (order_id FK, product_id FK, quantity, unit_price)   PK = (order_id, product_id)
     │ many
     │
     │ 1
products (product_id PK, name, category, price)
```

| Normal form | Rule of thumb |
|---|---|
| **1NF** | One value per cell; no repeating groups (no `phone1, phone2, phone3` columns) |
| **2NF** | Every column depends on the **whole** primary key |
| **3NF** | Columns depend **only** on the key, not on other non-key columns |

*"The key, the whole key, and nothing but the key."* Sometimes you deliberately **denormalize** for read performance (reporting tables, caches).

## 4. Operating databases: what DevOps engineers care about

| Concern | What to know |
|---|---|
| **Backups & restores** | Automated backups + point-in-time recovery; **test restores** |
| **High availability** | Replicas, automatic failover (RDS Multi-AZ) |
| **Scaling reads** | Read replicas, caching (Redis) |
| **Connections** | Each connection uses memory; use pooling (PgBouncer, RDS Proxy) |
| **Migrations** | Schema changes as versioned code (Flyway, Liquibase, Alembic, Prisma); run them in CI/CD |
| **Monitoring** | CPU, memory, disk space, connections, slow queries, replication lag |
| **Security** | Private subnets, no public access, encryption, least-privilege DB users, secrets in Secrets Manager |

## ✅ Self-check

- [ ] Explain PK vs FK and why constraints matter
- [ ] Write a query using JOIN, GROUP BY and HAVING
- [ ] Explain what an index is and when it doesn't help
- [ ] Explain ACID with a bank-transfer example
- [ ] Normalize a messy spreadsheet into 3 tables
- [ ] Run PostgreSQL in Docker, load the practice schema and back it up with `pg_dump`

➡️ **Next:** [08 · Careers & certifications](../08-careers/)
