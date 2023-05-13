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

## pgquarrel
[pgquarrel](https://github.com/eulerto/pgquarrel) is a tool that compares PostgreSQL schemas and generates SQL
commands to migrate from one to another; you need to install it from source.
```bash
# Clone the pgquarrel repository from GitHub
git clone https://github.com/eulerto/pgquarrel.git

cd pgquarrel # Enter the pgquarrel folder

# Create and enter the build folder
mkdir build && cd build

# Generate the Makefile using cmake
cmake ..

# Compile the source code using make
make

# Install the tool on your system using make install
make install
```

## How to create migrations
```bash
./create-migration.sh
```

- The script will first apply the `app.sql` file to the develop database, using the `psql` command.
- Then, it will use the `pgquarrel` tool to compare the develop and prod databases and output the differences as SQL commands.
- Next, it will prompt you to enter a name for the migration file. If you
  enter anything other than `n`, it will create a file in the `migrations`
  folder with the current timestamp and your input as the name. For example, if
  you enter `add_column`, it will create a file named
  `migrations/1620859200_add_column.sql`.

## How to apply migrations

[shmig](https://github.com/mbucc/shmig) is a simple shell script that manages database migrations using SQL
files.

- Run `docker-compose run --rm shmig up` to apply all pending migrations to the database.
- Run `docker-compose run --rm shmig down` to revert the last applied migration from the database.
- Run `docker-compose run --rm shmig status` to check the status of the migrations.
- Run `docker-compose exec -it psql -c "NOTIFY pgrst, 'reload schema'"` sql code to reload postgrest schema.

