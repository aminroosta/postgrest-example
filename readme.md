# PostgREST Docker Compose

This project uses docker-compose to run a PostgREST server with a PostgreSQL
database and a Swagger UI for documentation.

## Requirements

- Docker
- Docker Compose
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


## How to use Flyway with Docker Compose

Flyway is a tool that helps you manage database migrations with ease and
confidence.

1. Write your migration scripts in SQL and save them in the `sql` directory.
   The scripts must follow the naming convention
   `V<version>__<description>.sql`. For example, `V1__create_table.sql` or
   `V2__add_column.sql`. The version must be a positive integer and must be
   unique. The description can be any text that describes the migration.

2. Run `docker-compose up -d` to start all the services in detached mode.

3. <details><summary>Run `docker-compose logs flyway` to see the output of the
   flyway command. You should see something like this:</summary>

   ```
   flyway_1  | Flyway Community Edition 8.2.3 by Redgate
   flyway_1  | Database: jdbc:postgresql://postgres/mydb (PostgreSQL 14.1)
   flyway_1  | Successfully validated 2 migrations (execution time 00:00.021s)
   flyway_1  | Creating Schema History table "public"."flyway_schema_history" ...
   flyway_1  | Current version of schema "public": << Empty Schema >>
   flyway_1  | Migrating schema "public" to version "1 - create table"
   flyway_1  | Migrating schema "public" to version "2 - add column"
   flyway_1  | Successfully applied 2 migrations to schema "public" (execution time 00:00.041s)
   ```
   </details>

5. You can verify that the migrations have been applied by connecting to the
   PostgreSQL database and querying the tables. For example, you can run
   `docker exec -it postgres psql` to open a psql shell and then run `\dt` to
   list the tables or `SELECT * FROM <table_name>` to query a table.

6. To apply more migrations, you can add more scripts to the `sql` directory
   and then run `docker run --rm flyway migrate` again. Flyway will only apply the new
   migrations that have not been applied before.

7. To undo a migration, you can use the `undo` command instead of `migrate`.
   However, this requires that you have undo scripts in your `sql` directory
   that follow the naming convention `U<version>__<description>.sql`. For
   example, `U1__drop_table.sql` or `U2__remove_column.sql`. The version must
   match the version of the migration script that you want to undo.
