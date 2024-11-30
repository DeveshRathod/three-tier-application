provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}


# terraform {
#   backend "s3" {
#     bucket         = "<BUCKET_NAME>"
#     key            = "terraform/state"
#     region         = "ap-south-1"
#     encrypt        = true
#   }
# }
