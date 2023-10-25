#!/bin/bash

#
# making portalbot
#

# but first wait for REMS to be up
while ! curl -s http://localhost:3000 2>&1 1>/dev/null; do
   echo " - [ makeusers.sh ] REMS not yet up, waiting ..."
   sleep 1;
done
echo " - [ makeportalbot.sh ] REMS is up! continue the installation ..."
echo " - [ makeportalbot.sh ] creating user portalbot ..." 
curl -X POST http://localhost:3000/api/users/create -H "content-type: application/json" -H "x-rems-api-key: $REMS_API_KEY" -H "x-rems-user-id: $REMS_OWNER" -d '{ "userid": "portalbot", "name": "Portal Robot for reading and creating resources and catalogues", "email": null }'
echo " - [ makeportalbot.sh ] making portalbot as owner ..." 
java -Drems.config=config.edn -jar rems_${REMS_VERSION}.jar grant-role owner portalbot
echo " - [ makeportalbot.sh ] adding portalbot permissions to access /api/ paths ..." 
java -Drems.config=config.edn -jar rems_${REMS_VERSION}.jar api-key allow ${REMS_PORTALBOT_KEY} any '/api/(catalogue|catalogue-items|resources)/.*'
echo " - [ makeportalbot.sh ] assigning api-key to portalbot ..." 
java -Drems.config=config.edn -jar rems_${REMS_VERSION}.jar api-key set-users ${PORTALBOT_KEY} portalbot

