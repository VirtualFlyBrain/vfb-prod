FROM virtualflybrain/docker-vfb-neo4j:4.2-enterprise

VOLUME /backup

ENV NEOREADONLY=false

ENV BACKUPFILE="neo4j.dump"

ENV NEO4J_AUTH=neo4j/neo
ENV NEO4J_dbms_security_auth__enabled=true
ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=false
ENV NEO4J_dbms_query__cache__size=0
ENV NEO4J_dbms_default__listen__address=0.0.0.0
ENV NEO4J_dbms_connector_http_advertised__address=0.0.0.0:7474
ENV NEO4J_dbms_connector_bolt_advertised__address=0.0.0.0:7687
ENV NEO4J_dbms_connector_http_listen__address=0.0.0.0:7474
ENV NEO4J_dbms_connector_bolt_listen__address=0.0.0.0:7687
ENV NEO4J_dbms_security_procedures_unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*
ENV NEO4J_dbms_jvm_additional="-Dlog4j2.formatMsgNoLookups=true -Dlog4j2.disable.jmx=true"
# Pin GDS only - APOC pinned below as a jar to avoid Guava version conflict with NEO4JLABS_PLUGINS auto-download
ENV NEO4JLABS_PLUGINS='["graph-data-science"]'

RUN apt-get -y update && apt-get -y install tar gzip curl wget zip unzip

COPY loadKB.sh /opt/VFB/
ADD https://github.com/VirtualFlyBrain/neo4j2owl/releases/download/1.2.3-PRE/neo4j2owl.jar /var/lib/neo4j/plugins/neo4j2owl.jar
# Pin APOC 4.2.x explicitly - NEO4JLABS_PLUGINS downloads an incompatible version causing Guava IncompatibleClassChangeError
ADD https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/4.2.0.9/apoc-4.2.0.9-all.jar /var/lib/neo4j/plugins/apoc.jar

RUN mkdir -p /opt/VFB/backup/

RUN chmod -R 777 /opt/VFB/backup/

RUN chmod +x /opt/VFB/loadKB.sh

ENTRYPOINT ["/opt/VFB/loadKB.sh"]
