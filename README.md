# Local portal: a Proof of Concept implementation

Repository is holding the `docker-compose` environment that configures from scratch the
 - `Localportal` (Molgenis) - to hold the GDI metadata, exposed via various interfaces: web page, FDP, Beacon
 - `REMS` from vanilla environment - for Data access requests, automatically from Localportal > Dataset
 - `Keycloak` - for a central AAI
 - and a `Postgres` instance holding all three databases


## Clone repository to server

Clone the repository and navigate to proof-of-concept branch

    $ git clone https://github.com/molgenis/localportal.git

Add keycloak to /etc/hosts on the machine the docker compose is running, example

```
    127.0.0.1   localhirods-localost localhost.localdomain localhost4 localhost4.localdomain4 aai-mock keycloak postgres rems localportal
```

Spin up docker compose

    $ docker-compose up -d

to bring up

ports exposed:
 - 3000 rems
 - 5432 postgres
 - 8080 localportal
 - 9000 keycloak

docker compose exec localportal bash


where is stored waht
    postgres is permanent in ...

users per service

global shared environment

services are in /opt/{servicename} folders

# Local portal

localhost:8080 > signin
    lportaluser
    lportalpass

localhost:8080/apps/central/#/admin
    admin / admin

Logs for localportal
    docker-compose exec localportal /bin/bash
    localportal # cat /opt/localportal/install.log

# REMS

$ echo VERBOSE=2 >> /opt/rems/synchronization.config
$ /opt/rems/synchronization.sh


# Keycloak

keycloak:9000 (or localhost:9000) > Administration Console > admin:admin > switch realm from master to lportal
    > client > lportalclient >


# Postgres

the data is persistent across the restart of instance. In order to delete all the postgress data and start fresh

    $ sudo rm -rf postgres/psql_data/ ; mkdir postgres/psql_data/


# Shutting down

    $ docker compose down --rmi all -v                                  # shut down and remove all images and volumes
    $ sudo rm -rf postgres/psql_data/; mkdir postgres/psql_data/        # clean all the permanent postgres data
