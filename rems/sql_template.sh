#!/bin/bash

#define the SQL template from docker-compose variables
cat <<EOF >install.sql
INSERT INTO users(userid,userattrs) VALUES('${REMS_OWNER}','{"name": "Lportal User", "email": "some@e.mail", "userid": "${REMS_OWNER}"}');
INSERT INTO roles(userid,role) VALUES('${REMS_OWNER}','owner');
INSERT INTO api_key (apikey) VALUES ('${REMS_API_KEY}');
EOF
