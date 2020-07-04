#!/bin/sh
echo "set read only = ${NEOREADONLY} then launch neo4j service"
sed -i s/read_only=.*/read_only=${NEOREADONLY}/ ${NEOSERCONF} && \

echo 'Allow new neo4j2owl plugin to make changes..'
echo 'dbms.security.procedures.unrestricted=ebi.spot.neo4j2owl.*,apoc.*' >> ${NEOSERCONF}
#echo 'dbms.security.procedures.whitelist=ebi.spot.neo4j2owl.*,apoc.*' >> ${NEOSERCONF}

if [ ! -d /data/databases/graph.db ]; then
  if [ ! -d /backup/KBW-RESTORE.db ]; then
    echo 'Resore KB from archive backup'
    cd /opt/VFB/backup/
    rm /opt/VFB/backup/VFB-KB2.tar.gz
    wget http://data.virtualflybrain.org/archive/VFB-KB2.tar.gz 
    tar -xzvf VFB-KB2.tar.gz
    mkdir -p /backup/KBW-RESTORE.db/
    find /opt/VFB/backup/ -name 'KBW-RESTORE.db' -exec cp -vr "{}" /backup/ +
    rm -rf /opt/VFB/backup/*
    cd -
  fi
  if [ -d /backup/KBW-RESTORE.db ]; then
    echo 'Resore KB from given backup'
    /var/lib/neo4j/bin/neo4j-admin restore --from=/backup/KBW-RESTORE.db --force=true
  fi
fi

echo -e '\nSTARTING VFB KB SERVER\n' >> /var/lib/neo4j/logs/query.log

#Output the query log to docker log:
tail -f /var/lib/neo4j/logs/query.log >/proc/1/fd/1 &
exec /docker-entrypoint.sh neo4j
