FROM virtualflybrain/docker-vfb-neo4j:4.2-enterprise

ENV NEOREADONLY=true

ENV BACKUPFILE="neo4j.dump"

ENV NEO4J_AUTH=neo4j/neo
ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=true
ENV NEO4J_dbms_default__listen__address=0.0.0.0
ENV NEO4J_dbms_connector_http_listen__address=0.0.0.0:7474
ENV NEO4J_dbms_connector_bolt_listen__address=0.0.0.0:7687
ENV NEO4J_dbms_security_procedures_unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*
ENV NEO4J_dbms_jvm_additional="-Dlog4j2.formatMsgNoLookups=true -Dlog4j2.disable.jmx=true"

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
