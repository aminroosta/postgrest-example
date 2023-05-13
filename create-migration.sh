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

# Get the next migration number
get_migration_number() {
  files=$(ls $1/V*)
  max=0
  for file in $files; do
    n=$(echo $file | cut -d'V' -f2 | cut -d'_' -f1)
    if [ $n -gt $max ]; then
      max=$n
    fi
  done
  max=$((max + 1))
  echo $max
}

# Ask to write the migration file
read -p "Migration file name:  " answer
if [ "$answer" != "n" ]; then
  number=$(get_migration_number ./migrations)
  answer="${answer// /_}"
  migration_file="migrations/V${number}__${answer}.sql"
  pgquarrel -c pgquarrel.conf > $migration_file
  echo "Wrtoe $migration_file"

  echo "\n"
  read -p "Apply the migration? (Y/n) " answer

  if [ -z "$answer" ] || [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    docker-compose run --rm flyway migrate
  fi
fi


