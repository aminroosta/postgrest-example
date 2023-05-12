# PostgREST Docker Compose

This project uses docker-compose to run a [PostgREST](https://postgrest.org/en/stable/) server with a PostgreSQL
database and a Swagger UI for documentation.

## Requirements

- Docker & Docker Compose
- A `.envrc` file with the following variables:
  - `PGUSER`: the PostgreSQL user name
  - `PGPASSWORD`: the PostgreSQL user password
  - `PGDATABASE`: the PostgreSQL database name

## Usage

To start the services, run:
```bash
docker-compose up -d
```

To stop the services, run:
```bash
docker-compose down
```

To access the PostgREST server, go to http://localhost:3000/
To access the Swagger UI, go to http://localhost:8080/
To execute SQL commands on the PostgreSQL database, run:
```bash
docker exec -it postgres psql
```
## How to use Shmig

Shmig is a simple shell script that manages database migrations using SQL
files. You can find more information about Shmig at https://github.com/mbucc/shmig.

To use Shmig with this project, follow these steps:
- Run `docker-compose run --rm shmig create posts_table` to create a new
migration file in the `migrations` folder with the following
naming convention: `<unix_epoch>_migration_name.sql`.

```sql
-- Migration: posts_table
-- Created at: 2021-12-15 12:30:00
-- ====  UP  ====
BEGIN;

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMIT;

-- ==== DOWN ====
BEGIN;

DROP TABLE posts;

COMMIT;
```
- Run `docker-compose run --rm shmig up` to apply all pending migrations to the database.
- Run `docker-compose run --rm shmig down` to revert the last applied migration from the database.
- Run `docker-compose run --rm shmig status` to check the status of the migrations.
- Run `NOTIFY pgrst, 'reload schema';` sql code to reload postgrest schema.
