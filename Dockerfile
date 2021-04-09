FROM virtualflybrain/docker-vfb-neo4j:4.2-enterprise

ENV NEOREADONLY=true

ENV BACKUPFILE="VFB-PDB2-v4"

ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=true
ENV NEO4J_dbms_security_procedures_unrestricted=ebi.spot.neo4j2owl.*,apoc.*,gds.*

RUN apt-get -y update && apt-get -y install tar gzip curl wget

COPY loadKB.sh /opt/VFB/

###### APOC TOOLS ######
ENV APOC_VERSION=4.2.0.1
ARG APOC_JAR=https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/$APOC_VERSION/apoc-$APOC_VERSION-all.jar
ENV APOC_JAR ${APOC_JAR}
RUN wget $APOC_JAR -O /var/lib/neo4j/plugins/apoc.jar

###### GDS TOOLS ######
ENV GDS_VERSION=1.5.1
ARG GDS_JAR=https://s3-eu-west-1.amazonaws.com/com.neo4j.graphalgorithms.dist/graph-data-science/neo4j-graph-data-science-$GDS_VERSION-standalone.zip
ENV GDS_JAR ${GDS_JAR}
RUN wget $GDS_JAR -O /var/lib/neo4j/plugins/gds.zip && unzip tmp.zip && rm tmp.zip

RUN mkdir -p /opt/VFB/backup/ 

RUN chmod -R 777 /opt/VFB/backup/ 

RUN chmod +x /opt/VFB/loadKB.sh

ENTRYPOINT ["/opt/VFB/loadKB.sh"]
