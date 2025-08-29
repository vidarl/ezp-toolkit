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



create_response=`curl --silent -XPOST \
  --header "Accept: application/vnd.ibexa.api.Content+json" \
  --header "Content-Type: application/vnd.ibexa.api.ContentCreate+json" \
  --header "X-CSRF-Token: $CSRF_TOKEN" \
  --cookie "$SESSION_NAME=$SESSION_VALUE" \
  --data '
{
  "ContentCreate": {
    "ContentType": {
      "_href": "/api/ibexa/v2/content/types/1"
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
          "fieldValue": "Article with rest"
        },
        {
          "fieldDefinitionIdentifier": "short_name",
          "languageCode": "eng-GB",
          "fieldTypeIdentifier": "ezstring",
          "fieldValue": "Article with rest - short"
        },
        {
          "fieldDefinitionIdentifier": "short_description",
          "languageCode": "eng-GB",
          "fieldTypeIdentifier": "ezrichtext",
          "fieldValue":
           {
                "xml": "<section xmlns=\"http://ibexa.co/namespaces/ezpublish5/xhtml5/edit\"><p>short description</p></section>"
            }
        },
        {
          "fieldDefinitionIdentifier": "description",
          "languageCode": "eng-GB",
          "fieldTypeIdentifier": "ezrichtext",
          "fieldValue": {
                "xml": "<section xmlns=\"http://ibexa.co/namespaces/ezpublish5/xhtml5/edit\"><p>my long description</p></section>"
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


publish_response=`curl --silent -XPUBLISH \
  --header "X-CSRF-Token: $CSRF_TOKEN" \
  --cookie "$SESSION_NAME=$SESSION_VALUE" \
  ${API_URL}/content/objects/${contentId}/versions/${versionNo}
  `


#echo $create_response
echo $publish_response
