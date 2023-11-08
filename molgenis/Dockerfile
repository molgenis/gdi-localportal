FROM molgenis/molgenis-emx2:latest

WORKDIR /opt/molgenis

RUN apt-get -y install vim jq && apt-get clean all

COPY --chmod=0755 ./*.template ./*.sh ./*.csv ./
WORKDIR /opt/molgenis/sample_data
COPY --chmod=0644 ./sample_data/*.csv ./
WORKDIR /opt/molgenis

RUN /bin/bash -c "source install.sh.template && chmod 755 install.sh && source synchronization.config.template"

# Starting all the processes in parallel
#  - install script detects if needs to configure the service,
#  - synchronization is running in the background, but the ouput is redirected to a log file,
#  - the molgenis java output is redirected to a log of the docker instance
ENTRYPOINT /bin/bash -c "{ source install.sh 2>&1 1>install.sh.log & } && { source synchronization.sh 2>&1 1>synchronization.sh.log & } && java -jar /app.jar"
