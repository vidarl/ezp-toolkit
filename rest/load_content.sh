#!/bin/bash

API_URL=${BASE_URL}/api/ibexa/v2

if [ "$BASE_URL" = "" ]; then
  echo Error: BASE_IRL not set
  echo Maybe do : export BASE_URL=http://localhost:8080
  exit 1
fi

if [ "$CSRF_TOKEN" = "" ]; then
  echo Error: CSRF_TOKEN not set
  echo Maybe you forgot to run login.sh?
  exit 1
fi

if [ "$1" = "" ]; then
  echo You need to specify contentId
  exit 1
fi

content_id=$1


#curl --silent -XPOST \
load_response=`curl --silent -XGET \
  --header "Accept: application/vnd.ibexa.api.Content+json" \
  --header "X-CSRF-Token: $CSRF_TOKEN" \
  --cookie "$SESSION_NAME=$SESSION_VALUE" \
  ${API_URL}/content/objects/$content_id
  `

#echo $create_response
echo $load_response
