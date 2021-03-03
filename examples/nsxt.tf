variable "nsx_manager_ova_name" {
}

variable "nsx_controller_ova_name" {
}

variable "nsx_edge_ova_name" {
}

variable "nsx_license" {
}

variable "nsx_domain_0" {
  default = "metal.local"
}

terraform {
  required_providers {
    nsxt = {
      source  = "vmware/nsxt"
      version = "3.1.0"
    }
  }
}

module "nsx-dc" {
  source      = "./modules/nsxtdc"
  router_host = module.vsphere.metal_device.router.access_public_ipv4

  ssh_private_key         = chomp(module.vsphere.tls_private_key.ssh_key_pair.private_key_pem)
  nsx_manager_ova_name    = var.nsx_manager_ova_name
  nsx_controller_ova_name = var.nsx_controller_ova_name
  nsx_edge_ova_name       = var.nsx_edge_ova_name
  nsx_domain_0            = var.nsx_domain_0

  nsx_license = var.nsx_license

  vcva_host     = "vcva.metal.local"
  vcva_user     = "Administrator@vsphere.local"
  vcva_password = random_string.sso_password.result
  # Using S3-compatible Object Storage
  s3_boolean     = var.s3_boolean
  s3_url         = var.s3_url
  s3_access_key  = var.s3_access_key
  s3_secret_key  = var.s3_secret_key
  s3_bucket_name = var.s3_bucket_name
  # Using GCS
  storage_reader_key_name = var.storage_reader_key_name
  gcs_bucket_name         = var.gcs_bucket_name
}

output "nsx-datacenter-pasword" {
  value = module.nsx-dc.nsx_password
}

output "nsx-datacenter-cli-password" {
  value = module.nsx-dc.nsx_cli_password
}

provider "nsxt" {
  host                  = "" #This value will be in vSphere after the above module deploys.
  username              = "admin"
  password              = module.nsx-dc.nsx_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
  license_keys          = [var.nsx_license]
}

