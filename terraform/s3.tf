resource "aws_s3_bucket" "backup-storage" {
  bucket        = var.backup-storage-bucket-name
  acl           = "private"
  force_destroy = var.force-destroy-back-bucket

  tags = {
    Name        = var.backup-storage-bucket-name
    Environment = "Dev"
  }
}


resource "aws_s3_bucket" "waypoint-loadbalancers-logs" {
  bucket        = var.waypoint-loadbalancers-log-bucket
  acl           = "private"
  force_destroy = var.force-destroy-back-bucket

  tags = {
    Name        = var.waypoint-loadbalancers-log-bucket
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "waypoint-loadbalancers-logs-policy" {
  bucket = aws_s3_bucket.waypoint-loadbalancers-logs.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}

data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.waypoint-loadbalancers-logs.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.waypoint-loadbalancers-logs.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }


  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.waypoint-loadbalancers-logs.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}