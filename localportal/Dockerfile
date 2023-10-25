FROM molgenis/molgenis-emx2:latest

WORKDIR /opt/localportal

RUN apt-get -y install vim jq && apt-get clean all

COPY --chmod=0755 ./*.template ./*.sh ./*.csv ./
#COPY --chmod=0755 ./synchronization.sh ./synchronization.sh
#COPY --chmod=0644 ./synchronization.config.template ./synchronization.config.template
#COPY --chmod=0644 ./*.csv ./

RUN /bin/bash -c "source install.sh.template && chmod 755 install.sh && source synchronization.config.template"
#RUN /bin/bash -c "source synchronization.config.template"

ENTRYPOINT /bin/bash -c "{ source install.sh 2>&1 1>install.sh.log & } && { source synchronization.sh 2>&1 1>synchronization.sh.log & } && java -jar /app.jar"
