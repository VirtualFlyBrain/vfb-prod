FROM virtualflybrain/docker-vfb-neo4j:enterprise

ENV NEOREADONLY=true

ENV NEO4J_dbms_memory_heap_maxSize=4G
ENV NEO4J_dbms_memory_heap_initial__size=1G
ENV NEO4J_dbms_read__only=true

RUN apk update && apk add tar gzip curl wget

COPY loadKB.sh /opt/VFB/
ADD neo4j2owl.jar /var/lib/neo4j/plugins/neo4j2owl.jar 

RUN chmod +x /opt/VFB/loadKB.sh

ENTRYPOINT ["/opt/VFB/loadKB.sh"]
