#!/bin/bash
echo "set read only = ${NEOREADONLY} then launch neo4j service"
sed -i s/read_only=.*/read_only=${NEOREADONLY}/ ${NEOSERCONF} && \

echo 'Allow new neo4j2owl plugin to make changes..'
echo 'dbms.security.procedures.unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*' >> ${NEOSERCONF}

if [ -n "${BACKUPFILE}" ]; then
  if [ ! -d /data/databases/neo4j ]; then
    if [ ! -f /backup/neo4j.dump ]; then
      echo 'Resore KB from archive backup'
      cd /backup/
      wget http://data.virtualflybrain.org/archive/${BACKUPFILE} 
      cd -
    fi
    if [ -f /backup/neo4j.dump ]; then
      echo 'Resore KB from given backup'
      /var/lib/neo4j/bin/neo4j-admin load --from=/backup/neo4j.dump --verbose --force
    fi
  fi
fi

echo -e '\nSTARTING VFB KB SERVER\n' >> /var/lib/neo4j/logs/query.log

chown -R neo4j /logs || :
chown -R neo4j /data || :
chown -R neo4j /import || :
chown -R neo4j /var/lib/neo4j/plugins || :
chmod -R 777 /logs || :
chmod -R 777 /data || :
chmod -R 777 /import || :
chmod -R 777 /var/lib/neo4j/plugins || :

#Output the query log to docker log:
tail -f /var/lib/neo4j/logs/query.log >/proc/1/fd/1 &

sleep 4m && cypher-shell -u neo4j -p ${NEO4J_AUTH/neo4j\//} -d system 'START DATABASE neo4j' 
exec /docker-entrypoint.sh neo4j
