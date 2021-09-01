terraform {
  required_version = ">= 0.14"
  required_providers {
    metal = {
      source  = "equinix/metal"
      version = "2.0.1"
    }
    ssh = {
      source  = "AndrewChubatiuk/ssh"
      version = "0.1.1"
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
    vsphere = {
      source = "hashicorp/vsphere"
    }
    nsxt = {
      source  = "vmware/nsxt"
      version = "3.1.0"
    }
  }
}
