terraform {
  required_version = "~> 1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "us-east-1" # リージョンのエイリアスを作成
  region = "us-east-1"
}


# 環境定義
variable "bucket_name" {}
variable "host_domain" {}
variable "api_domain" {}
