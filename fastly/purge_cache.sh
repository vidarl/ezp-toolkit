#!/bin/bash

#usage : purge_cache.sh <serviceID> <Fastly API Key> 

SERVICE_ID=$1
FASTLY_API_KEY=$2


# https://support.fastly.com/hc/en-us/community/posts/360040168591-Intro-to-using-curl-with-Fastly

curl -XPOST -H "Fastly-Key:$FASTLY_API_KEY" https://api.fastly.com/service/$SERVICE_ID/purge_all


