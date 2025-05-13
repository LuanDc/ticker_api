provider "aws" {
  access_key = "access_key_id"
  secret_key = "secret_access_key"
  region     = "us-east-1"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3             = "http://s3.localhost.localstack.cloud:4566"
  }
}

resource "aws_s3_bucket" "b3_stock_quotes" {
  bucket = "b3-stock-quotes"
}