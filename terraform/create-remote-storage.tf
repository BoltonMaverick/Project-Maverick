provider "aws" {
  region = "us-east-2"
}


terraform {
  backend "s3" {
    bucket = "test"
    key    = "marverick"
    region = "us-east-2"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "test"

  tags = {
    Name        = "mav-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "b1" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
