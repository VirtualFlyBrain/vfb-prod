#!/bin/bash
echo "set read only = ${NEOREADONLY} then launch neo4j service"
sed -i s/read_only=.*/read_only=${NEOREADONLY}/ ${NEOSERCONF} && \

echo 'Allow new neo4j2owl plugin to make changes..'
echo 'dbms.security.procedures.unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*' >> ${NEOSERCONF}
#echo 'dbms.security.procedures.whitelist=ebi.spot.neo4j2owl.*,apoc.*' >> ${NEOSERCONF}

if [ -n "${BACKUPFILE}" ]; then
  if [ ! -d /data/databases/neo4j ]; then
    echo 'Resore KB from archive backup'
    cd /opt/VFB/backup/
    rm /opt/VFB/backup/${BACKUPFILE}.tar.gz
    wget http://data.virtualflybrain.org/archive/${BACKUPFILE}.tar.gz 
    tar -xzvf ${BACKUPFILE}.tar.gz
    mkdir -p /var/lib/neo4j/data/databases/
    bkdir=$(ls /opt/VFB/backup/*/neostore)
    mv -v "${bkdir/\/neostore/}" /opt/VFB/backup/neo4j
    neo4j-admin restore --from /opt/VFB/backup/neo4j --force
    rm -rf /opt/VFB/backup/*
    cd -
  fi
fi

echo -e '\nSTARTING VFB KB SERVER\n' >> /var/lib/neo4j/logs/query.log

#Output the query log to docker log:
tail -f /var/lib/neo4j/logs/query.log >/proc/1/fd/1 &
chmod -R 777 /import || :
exec /docker-entrypoint.sh neo4j
