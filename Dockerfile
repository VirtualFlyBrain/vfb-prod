FROM virtualflybrain/docker-vfb-neo4j:4.4-enterprise

ENV NEOREADONLY=true

ENV BACKUPFILE="VFB-PDB2-v4"

ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=false
ENV NEO4J_dbms_security_procedures_unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*
ENV NEO4J_dbms_directories_import=import
ENV NEO4J_dbms_security_allow_csv_import_from_file_urls=true
# Log4J CVE-2021-44228 vulnerability Mitigation for Neo4j
ENV NEO4J_dbms_jvm_additional="-Dlog4j2.formatMsgNoLookups=true -Dlog4j2.disable.jmx=true"
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true

RUN apt-get -y update && apt-get -y install tar gzip curl wget zip unzip

COPY loadKB.sh /opt/VFB/

ADD neo4j2owl.jar /var/lib/neo4j/plugins/neo4j2owl.jar

###### APOC TOOLS ######
ENV APOC_VERSION=4.2.0.2
ARG APOC_JAR=https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/$APOC_VERSION/apoc-$APOC_VERSION-all.jar
ENV APOC_JAR ${APOC_JAR}
RUN wget $APOC_JAR -O /var/lib/neo4j/plugins/apoc.jar

###### GDS TOOLS ######
ENV GDS_VERSION=1.5.1
ARG GDS_JAR=https://s3-eu-west-1.amazonaws.com/com.neo4j.graphalgorithms.dist/graph-data-science/neo4j-graph-data-science-$GDS_VERSION-standalone.zip
ENV GDS_JAR ${GDS_JAR}
RUN wget $GDS_JAR -O /var/lib/neo4j/plugins/gds.zip && cd /var/lib/neo4j/plugins/ && unzip gds.zip && rm gds.zip

RUN mkdir -p /opt/VFB/backup/

RUN chmod -R 777 /opt/VFB/backup/

RUN chmod +x /opt/VFB/loadKB.sh

ENTRYPOINT ["/opt/VFB/loadKB.sh"]
