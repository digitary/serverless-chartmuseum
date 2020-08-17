provider "aws" {
  region = "eu-west-1"
}

module "deploy" {
  source = "../deploy/aws"
  s3_bucket = "digitary-core-dev-chart-museum"
  s3_bucket_region = "eu-west-1"
}