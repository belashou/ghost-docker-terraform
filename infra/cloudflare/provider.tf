terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2"
    }
  }
}