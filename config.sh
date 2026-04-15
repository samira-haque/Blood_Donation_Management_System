#!/bin/bash
DB_NAME="blood_donation_db"
DB_USER="postgres"
DB_PASS="1234"
DB_HOST="localhost"

export PGPASSWORD=$DB_PASS

run_query() {
    psql -U $DB_USER -d $DB_NAME -h $DB_HOST -c "$1" 2>/dev/null
}

run_query_output() {
    psql -U $DB_USER -d $DB_NAME -h $DB_HOST -t -A -F'|' -c "$1" 2>/dev/null
}
