#!/bin/bash

API_URL=${BASE_URL}/api/ibexa/v2

if [ "$BASE_URL" = "" ]; then
  echo Error: BASE_URL not set
  echo Maybe do : export BASE_URL=http://localhost:8080
  exit 1
fi

# Create session
#curl --silent -XPOST \
session_response=`curl --silent -XPOST \
  --header "Accept: application/vnd.ibexa.api.JWT+json" \
  --header "Content-Type: application/vnd.ibexa.api.JWTInput+xml" \
  --data '<?xml version="1.0" encoding="UTF-8"?>
    <JWTInput>
        <username>admin</username>
        <password>publish</password>
    </JWTInput>' \
  ${API_URL}/user/token/jwt
  `

JWT_TOKEN=`echo $session_response | jq .JWT.token | tr -d '"'`


export JWT_TOKEN

echo $session_response | jq .
