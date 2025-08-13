#!/bin/bash


curl --request POST \
  --url http://localhost:8080/execute \
  --header 'content-type: application/json' \
  --data '{
  "type": "sysinfo"
}'

curl --request POST \
  --url http://localhost:8080/execute \
  --header 'content-type: application/json' \
  --data '{
  "type": "ping", "payload": "https://google.com"
}'