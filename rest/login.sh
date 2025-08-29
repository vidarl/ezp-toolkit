#!/bin/bash

API_URL=${BASE_URL}/api/ibexa/v2

if [ "$BASE_URL" = "" ]; then
  echo Error: BASE_URL not set
  echo Maybe do : export BASE_URL=http://localhost:8080
  exit 1
fi

# Create session
session_response=`curl --silent -XPOST \
  --header "Accept: application/vnd.ibexa.api.Session+json" \
  --header "Content-Type: application/vnd.ibexa.api.SessionInput+xml" \
  --data '<?xml version="1.0" encoding="UTF-8"?>
        <SessionInput>
          <login>admin</login>
          <password>publish</password>
        </SessionInput>' \
  ${API_URL}/user/sessions
  `
SESSION_NAME=`echo $session_response | jq .Session.name | tr -d '"'`
SESSION_VALUE=`echo $session_response | jq .Session._href | tr -d '"' | xargs basename`
CSRF_TOKEN=`echo $session_response | jq .Session.csrfToken | tr -d '"'`


export SESSION_NAME SESSION_VALUE CSRF_TOKEN

#echo $session_response | jq .
