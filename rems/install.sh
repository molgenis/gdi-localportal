#!/bin/bash

if ! PGPASSWORD=${REMS_PGPASS} psql -h postgres -p 5432 -d remsdb -U remsuser -c "SELECT * FROM roles WHERE userid = '${REMS_OWNER}'" 2>&1 1>/dev/null; then
   # configuring main REMS settings
   echo " - [ install.sh ] running REMS migration ..."
   java -Drems.config=config.edn -jar /opt/rems/rems_${REMS_VERSION}.jar migrate
   echo " - [ install.sh ] creating .sql from template ..."
   source ./sql_template.sh
   echo " - [ install.sh ] configuring REMS (running .sql) ..." 
   PGPASSWORD=${REMS_PGPASS} psql -h postgres -p 5432 -d remsdb -U remsuser < install.sql
fi
