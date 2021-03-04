#!/bin/sh
echo "set read only = ${NEOREADONLY} then launch neo4j service"
sed -i s/read_only=.*/read_only=${NEOREADONLY}/ ${NEOSERCONF} && \

echo 'Allow new neo4j2owl plugin to make changes..'
echo 'dbms.security.procedures.unrestricted=ebi.spot.neo4j2owl.*,apoc.*' >> ${NEOSERCONF}
#echo 'dbms.security.procedures.whitelist=ebi.spot.neo4j2owl.*,apoc.*' >> ${NEOSERCONF}

echo -e '\nSTARTING VFB KB SERVER\n' >> /var/lib/neo4j/logs/query.log

if [ -z "$(ls -A /var/lib/neo4j/import)" ]; then
  echo "Transfering CSVs to import"
  cp -R $CSV_IMPORTS/. /var/lib/neo4j/import
fi

#Output the query log to docker log:
tail -f /var/lib/neo4j/logs/query.log >/proc/1/fd/1 &
exec /docker-entrypoint.sh neo4j
