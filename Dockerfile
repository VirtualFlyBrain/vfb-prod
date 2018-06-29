FROM virtualflybrain/docker-vfb-neo4j:enterprise

ENV NEOREADONLY=true

ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=true

RUN apk update && apk add tar gzip curl wget

COPY loadKB.sh /opt/VFB/
RUN wget https://github.com/VirtualFlyBrain/neo4j2owl/releases/download/1.1.1-PRE/neo4j2owl-1.1.1.jar -P /var/lib/neo4j/plugins

RUN chmod +x /opt/VFB/loadKB.sh

ENTRYPOINT ["/opt/VFB/loadKB.sh"]
