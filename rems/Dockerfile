FROM rockylinux:9-minimal
MAINTAINER s.cimerman@umcg.nl
LABEL Remarks="UMCG/REMS"
WORKDIR /
ARG REMS_VERSION
RUN microdnf install -y curl java sudo jq lsof postgresql && microdnf clean all

WORKDIR /opt/rems
RUN curl -L -k "https://github.com/CSCfi/rems/releases/download/v${REMS_VERSION}/rems.jar" -o "/opt/rems/rems_${REMS_VERSION}.jar"
COPY ./config.edn /opt/rems/config.edn
COPY --chmod=0644 ./install.sh /opt/rems/install.sh
COPY --chmod=0644 ./sql_template.sh ./sql_template.sh
COPY --chmod=755 ./makeportalbot.sh ./makeportalbot.sh
COPY --chmod=0755 ./rems_create_static_content.sh ./rems_create_static_content.sh

ENTRYPOINT /bin/bash -c "source ./install.sh && { source makeportalbot.sh 2>&1 1>makeportalbot.sh.log & } && { source ./rems_create_static_content.sh 2>&1 1>rems_create_static_content.sh.log & } && java -Drems.config=/opt/rems/config.edn -jar /opt/rems/rems_${REMS_VERSION}.jar run"
#ENTRYPOINT sleep 3600

