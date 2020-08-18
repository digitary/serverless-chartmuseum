provider "aws" {
  region = "eu-west-1"
}

module "deploy" {
  source           = "../deploy/aws"
  s3_bucket        = "your s3 bucket name here"
  s3_bucket_region = "your s3 bucket's region here"
}

