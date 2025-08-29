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



#curl --silent -XPOST \
create_response=`curl --silent -XPOST \
  --header "Accept: application/vnd.ibexa.api.Content+json" \
  --header "Content-Type: application/vnd.ibexa.api.ContentCreate+json" \
  --header "X-CSRF-Token: $CSRF_TOKEN" \
  --cookie "$SESSION_NAME=$SESSION_VALUE" \
  --data '
{
  "ContentCreate": {
    "ContentType": {
      "_href": "/api/ibexa/v2/content/types/42"
      },
    "mainLanguageCode": "eng-GB",
    "LocationCreate": {
      "ParentLocation": {
        "_href": "/api/ibexa/v2/content/locations/1/2/460"
       },
      "priority": "0",
      "hidden": "false",
      "sortField": "PATH",
      "sortOrder": "ASC"
    },
    "Section": {
      "_href": "/api/ibexa/v2/content/sections/1"
    },
    "alwaysAvailable": "true",
    "fields": {
      "field": [
        {
          "fieldDefinitionIdentifier": "name",
          "languageCode": "eng-GB",
          "fieldTypeIdentifier": "ezstring",
          "fieldValue": "Landing page test"
        },
        {
          "fieldDefinitionIdentifier": "description",
          "languageCode": "eng-GB",
          "fieldTypeIdentifier": "ezstring",
          "fieldValue": "landing description"
        },
        {
          "fieldDefinitionIdentifier": "page",
          "languageCode": "eng-GB",
          "fieldTypeIdentifier": "ezlandingpage",
          "fieldValue":
          {
            "layout":"default",
            "zones":[
              {
                "id":"7752",
                "name":"default",
                "blocks":[
                  {
                    "visible":true,
                    "id":"19287",
                    "type":"richtext",
                    "name":"Text",
                    "view":"default",
                    "class":null,
                    "style":null,
                    "compiled":"",
                    "since":null,
                    "till":null,
                    "attributes":[
                      {
                        "id":"25766",
                        "name":"content",
                        "value":"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<section xmlns=\"http:\/\/docbook.org\/ns\/docbook\" xmlns:xlink=\"http:\/\/www.w3.org\/1999\/xlink\" xmlns:ezxhtml=\"http:\/\/ibexa.co\/xmlns\/dxp\/docbook\/xhtml\" xmlns:ezcustom=\"http:\/\/ibexa.co\/xmlns\/dxp\/docbook\/custom\" version=\"5.0-variant ezpublish-1.0\"><para>sdfsdf<\/para><\/section>\n"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        }
      ]
    }
  }
}
  ' \
  ${API_URL}/content/objects
  `
contentId=`echo $create_response | jq .Content._id`
versionNo=`echo $create_response | jq .Content.currentVersionNo`

echo "Create response :"
echo $create_response
echo -e "\n\n"

publish_response=`curl --silent -XPUBLISH \
  --header "X-CSRF-Token: $CSRF_TOKEN" \
  --cookie "$SESSION_NAME=$SESSION_VALUE" \
  ${API_URL}/content/objects/${contentId}/versions/${versionNo}
  `


#echo $create_response
echo $publish_response
