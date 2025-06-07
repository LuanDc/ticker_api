provider "aws" {
  region     = "us-east-1"
}

# SQS Queue

resource "aws_sqs_queue" "ticker_file_uploaded_queue" {
  name = "ticker-file-uploaded-queue"
  visibility_timeout_seconds = 600
}

# SNS Topic

resource "aws_sns_topic" "ticker_file_uploaded_notifications" {
  name = "ticker-file-uploaded-notifications"
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.ticker_file_uploaded_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.ticker_file_uploaded_queue.arn
}

# S3 Bucket

resource "aws_s3_bucket" "b3_tickers" {
  bucket = "b3-tickers"
}

resource "aws_s3_bucket_notification" "ticker_file_uploaded_notifications" {
  bucket = aws_s3_bucket.b3_tickers.id

  topic {
    topic_arn = aws_sns_topic.ticker_file_uploaded_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# IAM

resource "aws_sns_topic_policy" "ticker_file_uploaded_notifications_policy" {
  arn = aws_sns_topic.ticker_file_uploaded_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.ticker_file_uploaded_notifications.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn": aws_s3_bucket.b3_tickers.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "ticker_file_uploaded_queue_policy" {
  queue_url = aws_sqs_queue.ticker_file_uploaded_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = "SQS:SendMessage"
        Resource = aws_sqs_queue.ticker_file_uploaded_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn": aws_sns_topic.ticker_file_uploaded_notifications.arn
          }
        }
      }
    ]
  })
}
