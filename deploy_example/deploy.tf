provider "aws" {
  region = "eu-west-1"
}

module "deploy" {
  source           = "../deploy/aws"
  s3_bucket        = "an existing s3 bucket to store the charts in"
  s3_bucket_region = "eu-west-1"
}

