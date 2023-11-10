terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1"
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