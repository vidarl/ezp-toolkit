#!/bin/bash

# current_user_context is a custom REST endpoint

API_URL=${BASE_URL}/api/ibexa/v2

if [ "$BASE_URL" = "" ]; then
  echo Error: BASE_IRL not set
  echo Maybe do : export BASE_URL=http://localhost:8080
  exit 1
fi

if [ "$JWT_TOKEN" = "" ]; then
  echo Error: CSRF_TOKEN not set
  echo Maybe you forgot to run login_jwt.sh?
  exit 1
fi


#curl --silent -XPOST \

#  --header "Accept: application/vnd.ibexa.api.Content+json" \
load_response=`curl --silent -XGET \
  --header "Authorization: Bearer $JWT_TOKEN" \
  --header "X-Siteaccess: site" \
  ${API_URL}/current_user_context
  `

#echo $create_response
echo $load_response
