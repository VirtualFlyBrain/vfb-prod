#!/bin/bash
echo "set read only = ${NEOREADONLY} then launch neo4j service"
sed -i s/read_only=.*/read_only=${NEOREADONLY}/ ${NEOSERCONF} && \

echo 'Allow new neo4j2owl plugin to make changes..'
echo 'dbms.security.procedures.unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*' >> ${NEOSERCONF}

echo -e '\nSTARTING VFB KB SERVER QUERY LOG\n' >> /var/lib/neo4j/logs/query.log
echo -e '\nSTARTING VFB KB SERVER DEBUG LOG\n' >> /var/lib/neo4j/logs/debug.log
echo -e '\nSTARTING VFB KB SERVER SECURITY LOG\n' >> /var/lib/neo4j/logs/security.log

ls -la /plugins/ || :
ls -la /var/lib/neo4j/plugins/ || :

chown -R neo4j.neo4j /logs || :
chown -R neo4j.neo4j /data || :
chown -R neo4j.neo4j /import || :
chown -R neo4j.neo4j /var/lib/neo4j/plugins || :
chmod -R 777 /logs || :
chmod -R 777 /data || :
chmod -R 777 /import || :
chmod -R 777 /var/lib/neo4j/plugins || :

#Output the query log to docker log:
tail -f /var/lib/neo4j/logs/query.log >/proc/1/fd/1 &
tail -f /var/lib/neo4j/logs/debug.log >/proc/1/fd/1 &
tail -f /var/lib/neo4j/logs/security.log >/proc/1/fd/1 &

sleep 4m && cypher-shell -u neo4j -p ${NEO4J_AUTH/neo4j\//} -d system 'START DATABASE neo4j' 
exec /docker-entrypoint.sh neo4j
