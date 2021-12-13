FROM virtualflybrain/docker-vfb-neo4j:4.2-community

ENV NEOREADONLY=true

ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=true
ENV NEO4J_dbms_security_procedures_unrestricted=ebi.spot.neo4j2owl.*,apoc.*

RUN apt-get -y update && apt-get -y install tar gzip curl wget

COPY loadKB.sh /opt/VFB/
ADD neo4j2owl.jar /var/lib/neo4j/plugins/neo4j2owl.jar 

###### APOC TOOLS ######
ENV APOC_VERSION=3.3.0.1
ARG APOC_JAR=https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/$APOC_VERSION/apoc-$APOC_VERSION-all.jar
ENV APOC_JAR ${APOC_JAR}
RUN wget $APOC_JAR -O /var/lib/neo4j/plugins/apoc.jar

RUN chmod +x /opt/VFB/loadKB.sh

ENTRYPOINT ["/opt/VFB/loadKB.sh"]
