# PostgREST Docker Compose

This project uses docker-compose to run a RESTful API server with PostgreSQL and Swagger UI. It also uses pgquarrel to migrate PostgreSQL schemas.

## Requirements

- Docker & Docker Compose
- A `.envrc` file with PostgreSQL user, password and database name

## Usage

- Run `docker-compose up -d` to start the services
- Go to http://localhost:3000/ for the API server
- Go to http://localhost:8080/ for the Swagger UI
- Run `docker exec -it postgres psql` to execute SQL commands on PostgreSQL

## pgquarrel

pgquarrel is a tool that compares and migrates PostgreSQL schemas. You need to install it from source:

```bash
git clone https://github.com/eulerto/pgquarrel.git
cd pgquarrel
mkdir build && cd build
cmake ..
make
make install
```

## How to create migrations

Run `./create-migration.sh` to compare the develop and prod databases and generate a migration file in the `migrations` directory. The script uses the `pgquarrel.conf` file for the connection details and options. See the file for more details.

The script will prompt you to apply the migration using Flyway.

## How to apply migrations

Flyway is a tool that manages database migrations. Migration scripts are in the `migrations` directory with the format `V<version>__<description>.sql`.

To apply migrations run `docker run --rm flyway migrate`. Flyway will only apply new migrations.

You can verify the migrations by querying the PostgreSQL database.

## How to test the API

You can use any HTTP client or the Swagger UI to test the API. Here are some curl examples:

- Get all todos: `curl http://localhost:3000/todos`
- Get a todo by id: `curl http://localhost:3000/todos?id=eq.1`
- Create a todo: `curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer <token>" -d '{"task": "write more readme", "due": "2023-05-13"}' http://localhost:3000/todos`
- Update a todo: `curl -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer <token>" -d '{"done": true}' http://localhost:3000/todos?id=eq.1`
- Delete a todo: `curl -X DELETE -H "Authorization: Bearer <token>" http://localhost:3000/todos?id=eq.1`

For more information on PostgREST, see https://postgrest.org/en/stable/.

## How to generate JSON Web Tokens

Run `docker-compose exec -it postgres psql` and then run `select auth.jwt_token('todo_user');` to get a token for the `todo_user` role. You can also pass other roles or claims as parameters. For more information on JSON Web Tokens, see https://postgrest.org/en/stable/auth.html.

## How to contribute

If you want to contribute, please follow these steps:

1. Fork and clone this repository
2. Create a new branch for your feature or bugfix
3. Make your changes and commit them
4. Push your branch and create a pull request
5. Wait for feedback and address any comments or requests

Thank you for your interest in this project!
