#!/bin/bash

: ${MYSQL_HOST=openmrs-mysql-db}
: ${MYSQL_ROOT_PASSWORD=secret_password}

export MYSQL_HOST
export MYSQL_ROOT_PASSWORD

USERNAME=admin;
POST_TEMPLATE=$(cat /postTemplate.json)

processFile() {
   REPORT_CONTENT=$(envsubst "`printf '${%s} ' $(bash -c "compgen -A variable")`"  < $1)
   REPORT_CONTENT="${REPORT_CONTENT//\"/\\\"}"
   REPORT_NAME=$(echo $2 | sed 's/\([A-Z][^A-Z]\)/ \1/g')

   POST_CONTENT=$(printf "$POST_TEMPLATE" "$REPORT_NAME" "$REPORT_CONTENT")

   curl -X POST -H "Content-Type: application/json" -u "$USERNAME:$DHIS_ADMIN_PASSWORD" \
   "http://localhost:8080/api/reports" -d "$(echo $POST_CONTENT)"
}

for file in /reports/*; do
  filename=$(basename "$file")
  fname="${filename%.*}"
  processFile $file $fname
done
