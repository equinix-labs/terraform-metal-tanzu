terraform {
  required_version = ">= 0.13"
  required_providers {
    metal = {
      source  = "equinix/metal"
      version = "1.0.0"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
    tls = {
      source = "hashicorp/tls"
    }
    nsxt = {
      source  = "vmware/nsxt"
      version = "3.1.0"
    }
  }
}