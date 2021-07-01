#!/bin/sh
###
# This is a startup script for the Waypoint runners
###
echo "Starting the Waypoint Runner"

## Get the current AWS Region
REGION=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)


## GET CONTEXT TOKEN
CONTEXT=$(aws ssm get-parameter --name "waypoint_context" --with-decryption --region $REGION | jq .Parameter.Value | sed 's/^.//;s/.$//' | sed 's/^.//;s/.$//' | sed 's/^.//;s/.$//') && CONTEXT="${CONTEXT%\"}" && CONTEXT="${CONTEXT#\"}"

## GET CUSTOM DOMAIN
DOMAIN=$(aws ssm get-parameter --name "waypoint_domain" --region $REGION | jq .Parameter.Value) && DOMAIN="${DOMAIN%\"}" && DOMAIN="${DOMAIN#\"}"

## START RUNNER
export WAYPOINT_SERVER_ADDR=https://${DOMAIN}:9701
export WAYPOINT_SERVER_TLS=true
export WAYPOINT_SERVER_TOKEN=$TOKEN
export WAYPOINT_SERVER_TLS_SKIP_VERIFY=true
waypoint runner agent