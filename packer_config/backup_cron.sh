#!/bin/sh
## INFO ###  The script expects the environement variable WAYPOINT_BACKUP_BUCKET to be available
# WAYPOINT_BACKUP_BUCKET is reserverd for the S3 bucket name.

## INFO ## Get AWS Region
REGION=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
# Get bucket location and remove quotes
WAYPOINT_BACKUP_BUCKET=$(aws ssm get-parameter --name "waypoint-backup-bucket" --region $REGION | jq .Parameter.Value) && WAYPOINT_BACKUP_BUCKET="${WAYPOINT_BACKUP_BUCKET%\"}" && WAYPOINT_BACKUP_BUCKET="${WAYPOINT_BACKUP_BUCKET#\"}"
# Take a snapshot of the server
waypoint server snapshot /opt/waypoint/backup.snap
# Format the file name for easy finding in S3
today=$(date "+%Y/%m/%d")
s3ObjectName=$(date "+%H-%M-%S")
mv /opt/waypoint/backup.snap /opt/waypoint/$s3ObjectName-backup.snap
# Upload to S3
aws s3 cp /opt/waypoint/$s3ObjectName-backup.snap s3://$WAYPOINT_BACKUP_BUCKET/$today/$s3ObjectName-backup.snap --region $REGION