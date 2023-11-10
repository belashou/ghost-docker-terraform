terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    random = {
      source = "hashicorp/random"
    }
    local = {
      source = "hashicorp/local"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.s3_access_key
  secret_key = var.s3_secret_key
  skip_credentials_validation = true
  skip_region_validation = true
  skip_requesting_account_id = true
  endpoints {
    s3 = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  }
}