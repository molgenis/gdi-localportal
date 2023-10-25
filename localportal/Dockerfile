FROM molgenis/molgenis-emx2:latest

WORKDIR /opt/localportal

RUN apt-get -y install vim jq && apt-get clean all

COPY --chmod=0755 ./install.sh.template ./install.sh.template
COPY --chmod=0755 ./synchronization.sh ./synchronization.sh
COPY --chmod=0644 ./synchronization.config.template ./synchronization.config.template
COPY --chmod=0644 ./*.csv ./

RUN /bin/bash -c "source install.sh.template"
RUN /bin/bash -c "chmod 755 /opt/localportal/install.sh"
RUN /bin/bash -c "source synchronization.config.template"

WORKDIR /
ENTRYPOINT /bin/bash -c "{ source /opt/localportal/install.sh 2>&1 1>/opt/localportal/install.sh.log & } && { source synchronization.sh 2>&1 1>synchronization.sh.log & } && java -jar /app.jar"
