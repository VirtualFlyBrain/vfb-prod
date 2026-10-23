FROM virtualflybrain/docker-vfb-neo4j:4.2-enterprise

VOLUME /backup

ENV NEOREADONLY=true

ENV BACKUPFILE="neo4j.dump"

ENV NEO4J_AUTH=neo4j/neo
ENV NEO4J_dbms_security_auth__enabled=true
ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=true
ENV NEO4J_dbms_query__cache__size=0
ENV NEO4J_dbms_default__listen__address=0.0.0.0
ENV NEO4J_dbms_connector_http_advertised__address=0.0.0.0:7474
ENV NEO4J_dbms_connector_bolt_advertised__address=0.0.0.0:7687
ENV NEO4J_dbms_connector_http_listen__address=0.0.0.0:7474
ENV NEO4J_dbms_connector_bolt_listen__address=0.0.0.0:7687
ENV NEO4J_dbms_security_procedures_unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*
ENV NEO4J_dbms_jvm_additional="-Dlog4j2.formatMsgNoLookups=true -Dlog4j2.disable.jmx=true"
# GDS pinned as a jar at build time (same as APOC/neo4j2owl). It used to be fetched by the entrypoint at every
# container start via NEO4JLABS_PLUGINS, which fails the start whenever graphdatascience.ninja is unreachable
# (seen 2026-10-23: "No jar URL found for version '4.2.19'"). 1.8.8 is the GDS build versions.json lists for 4.2.19.
ENV NEO4JLABS_PLUGINS='[]'
ADD https://graphdatascience.ninja/neo4j-graph-data-science-1.8.8.jar /var/lib/neo4j/plugins/graph-data-science.jar

# Debian bullseye reached end of LTS on 31 Aug 2026 and its -security pool has been removed from deb.debian.org
# while the index still lists it, so any install that resolves to a bullseye-security version 404s. Drop that
# source and take the bullseye/main versions instead (same fix as Docker-VFB-Neo4j-ProductionDB #9).
RUN sed -i '/bullseye-security/d' /etc/apt/sources.list \
 && apt-get -y update && apt-get -y install tar gzip curl wget zip unzip

COPY loadKB.sh /opt/VFB/
ADD https://github.com/VirtualFlyBrain/neo4j2owl/releases/download/1.2.3.8-PRE/neo4j2owl.jar /var/lib/neo4j/plugins/neo4j2owl.jar 

RUN mkdir -p /opt/VFB/backup/ 

RUN chmod -R 777 /opt/VFB/backup/ 

RUN chmod +x /opt/VFB/loadKB.sh

ENTRYPOINT ["/opt/VFB/loadKB.sh"]
