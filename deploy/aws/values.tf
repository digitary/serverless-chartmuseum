variable "s3_bucket" {
  description = "The s3 bucket to store helm charts"
}
variable "s3_bucket_region" {
  description = "The region the bucket is in"
}

variable "basic_auth_user" {
  description = "Optional basic authentication user"
  default = ""
}

variable "basic_auth_password" {
  description = "Optional basic authentication password"
  default = ""
}

variable "log_level" {
  default = "INFO"
  description = "The lambda log level"
}
