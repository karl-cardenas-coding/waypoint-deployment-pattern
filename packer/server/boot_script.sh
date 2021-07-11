#!/bin/sh
sleep 30
echo "Gathering Waypoint context token"
CONTEXT=$(cat /home/waypoint/.config/waypoint/context/install*.hcl | /usr/local/bin/./hclq get server.auth_token)
echo "Pushing token to SSM Parameter store"
aws ssm put-parameter --region us-east-1 \
    --name "waypoint_context" \
    --type "SecureString" \
    --value $CONTEXT \
    --tier "Standard" \
    --overwrite