set -e

# Apply the app.sql file to the develop database
psql \
  -h 127.0.0.1 \
  -p 5433 \
  -v ON_ERROR_STOP=1 \
  -f app.sql \
  > /dev/null

# Diff the develop database against the prod
pgquarrel -c pgquarrel.conf

# Ask to write the migration file
read -p "Migration file name:  " answer
if [ "$answer" != "n" ]; then
  migration_file="migrations/$(date +%s)_$answer.sql"
  pgquarrel -c pgquarrel.conf > $migration_file
  echo "Wrtoe $migration_file"

  echo "\n"
  read -p "Apply the migration? (Y/n) " answer


  if [ -z "$answer" ] || [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    docker-compose run --rm shmig up
    docker-compose run --rm shmig status
  fi
fi


