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

module "nsx-dc" {
  source      = "./modules/nsxtdc"
  router_host = module.vsphere.vpn_endpoint

  ssh_private_key         = chomp(file(module.vsphere.ssh_key_path))
  nsx_manager_ova_name    = var.nsx_manager_ova_name
  nsx_controller_ova_name = var.nsx_controller_ova_name
  nsx_edge_ova_name       = var.nsx_edge_ova_name
  nsx_domain_0            = var.nsx_domain_0

  # TODO nsx_license variable needed in nsxtdc module?
  # nsx_license = var.nsx_license

  vcva_host     = module.vsphere.vcenter_fqdn
  vcva_user     = module.vsphere.vcenter_username
  vcva_password = module.vsphere.vcenter_password
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
  # TODO This value will be in vSphere after the above module deploys.
  # TODO set it to the dynamic value
  host                  = ""
  username              = "admin"
  password              = module.nsx-dc.nsx_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
  license_keys          = [var.nsx_license]
}

