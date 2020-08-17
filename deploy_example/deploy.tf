provider "aws" {
  region = "eu-west-1"
}

module "deploy" {
  source = "../deploy/aws"
  s3_bucket = "s3 bucket to hold helm charts"
  s3_bucket_region = "eu-west-1"
}