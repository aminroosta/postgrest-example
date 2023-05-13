# PostgREST Docker Compose

This project uses docker-compose to run a [PostgREST](https://postgrest.org/en/stable/) server with
a PostgreSQL database and a Swagger UI for documentation.
It also uses [pgquarrel](https://github.com/eulerto/pgquarrel) to compare and migrate PostgreSQL schemas.

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

The `create-migration.sh` script uses the `pgquarrel` tool to compare the
schemas of the develop and prod databases and generate SQL commands to migrate
from one to another. The `pgquarrel` tool takes a configuration file as an
argument, which specifies the connection details and options for the
comparison. The script uses the `pgquarrel.conf` file in the project root
directory for this purpose.

The `pgquarrel.conf` file has three main sections: `[general]`, `[target]`,
and `[source]`. The `[general]` section defines some global settings for the
comparison, such as the temporary directory, the verbosity level, the summary
option, and the list of database objects to include or exclude. The `[target]`
and `[source]` sections define the connection details for the target and
source databases, respectively. The target database is the one that needs to
be migrated, and the source database is the one that serves as a reference.

The script first applies the `app.sql` file to the develop database using the
`psql` command. This file contains the application code that defines the
schema and roles for the API. Then, it runs the `pgquarrel` command with the
`-c pgquarrel.conf` option to compare the develop and prod databases. The
`pgquarrel` tool outputs the SQL commands that are needed to migrate the
target database (prod) to match the source database (develop). These commands
are then written to a migration file in the `migrations` directory with a
timestamp and a name provided by the user. Finally, the script prompts the
user to apply the migration using Flyway.

## How to apply migrations

Flyway is a tool that manages database migrations:

1. Migration scripts are written to the `migrations` directory.
   The scripts follow the naming convention
   `V<version>__<description>.sql`. For example, `V1__create_table.sql` or
   `V2__add_column.sql`.

2. <details><summary>Run `docker-compose logs flyway` to see the output of the
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

3. You can verify that the migrations have been applied by connecting to the
   PostgreSQL database and querying the tables. For example, you can run
   `docker exec -it postgres psql` to open a psql shell and then run `\dt` to
   list the tables or `SELECT * FROM <table_name>` to query a table.

4. To apply migrations run `docker run --rm flyway migrate`. Flyway will only apply the new
   migrations that have not been applied before.
   
   
## How to test the API

To test the API, you can use any HTTP client such as curl, Postman, or Insomnia. You can also use the Swagger UI to explore the API documentation and try out different requests.

Here are some examples of how to use curl to test the API:

- To get a list of all todos, run:
```bash
curl http://localhost:3000/todos
```

- To get a single todo by id, run:
```bash
curl http://localhost:3000/todos?id=eq.1
```

- To create a new todo, run:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"task": "write more readme", "due": "2023-05-13"}' \
  http://localhost:3000/todos
```
where `<token>` is a valid JSON Web Token that you can obtain from the `authenticator` role.

- To update an existing todo, run:
```bash
curl -X PATCH \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"done": true}' \
  http://localhost:3000/todos?id=eq.1
```

- To delete an existing todo, run:
```bash
curl -X DELETE \
  -H "Authorization: Bearer <token>" \
  http://localhost:3000/todos?id=eq.1
```

For more information on how to use PostgREST, please refer to the [official documentation](https://postgrest.org/en/stable/).

## How to generate JSON Web Tokens

```bash
docker-compose exec -it postgres psql

select auth.jwt_token('todo_user');
```
This will return a token that you can use to access the API as the `todo_user`
role. You can also pass other roles or claims as parameters to the function.
For example:
```bash
select auth.jwt_token('web_anon', 'email', 'test@example.com');
```
This will return a token that you can use to access the API as the `web_anon`
role with an additional claim of `email`. For more information on how to use
JSON Web Tokens with PostgREST, please refer to the [official
documentation](https://postgrest.org/en/stable/auth.html).

## How to contribute

If you want to contribute to this project, please follow these steps:

1. Fork this repository on GitHub and clone your fork locally.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit them with descriptive messages.
4. Push your branch to your fork and create a pull request on GitHub.
5. Wait for feedback and address any comments or requests.

Thank you for your interest in this project!

