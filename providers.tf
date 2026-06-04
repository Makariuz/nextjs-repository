terraform {
  cloud {
    organization = "makariuz-test"
    workspaces {
      name = "nextjs-repository"
    }
  }
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 1.1"
}

provider "hcloud" {
  token = var.hcloud_token
}
