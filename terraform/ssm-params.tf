resource "aws_ssm_parameter" "waypoint-context" {
  name  = "waypoint_context"
  type  = "SecureString"
  value = "default"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# The name of this parameter is expected by the backup_cron.sh script.
# DO NOT CHANGE UNLESS backup_cron.sh is modifed as well.
resource "aws_ssm_parameter" "waypoint-backup" {
  name  = "waypoint-backup-bucket"
  type  = "String"
  value = aws_s3_bucket.backup-storage.id
}

# This is used by the init-runner.sh script.
# It's how the runner becomes aware of the Waypoint server domain.
resource "aws_ssm_parameter" "waypoint-domain" {
  name  = "waypoint_domain"
  type  = "String"
  value = var.domain-name
}
