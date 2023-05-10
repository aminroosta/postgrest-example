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
