#!/bin/sh

# sign in and retrieve token
TOKEN=$(curl https://portal-gdi-nl.molgeniscloud.org/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { signin (email: \"admin\", password: \"Q._kXHR!wp2N_jsbHpEujPGQ\") { token } }"}' | python -c "import sys,json; data=json.load(sys.stdin); print(data['data']['signin']['token'])")

echo $TOKEN

# create a new schema using the FAIR_DATA_HUB template
curl https://portal-gdi-nl.molgeniscloud.org/api/graphql \
  -H "x-molgenis-token:${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createSchema(name: \"gdiportal\", template: \"FAIR_DATA_HUB\") { message }}"}'

  
# POST FILE
curl --data-binary @gdi_datasets.xlsx https://portal-gdi-nl.molgeniscloud.org/gdiportal/api/graphql