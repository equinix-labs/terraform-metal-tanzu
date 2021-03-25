module "nsx-dc" {
  source      = "./modules/nsxtdc"
  router_host = module.vsphere.vpn_endpoint

  ssh_private_key         = chomp(file(module.vsphere.ssh_key_path))
  nsx_manager_ova_name    = var.nsx_manager_ova_name
  nsx_controller_ova_name = var.nsx_controller_ova_name
  nsx_edge_ova_name       = var.nsx_edge_ova_name
  nsx_domain_0            = var.nsx_domain_0

  vcva_host     = module.vsphere.vcenter_fqdn
  vcva_user     = module.vsphere.vcenter_username
  vcva_password = module.vsphere.vcenter_password

  s3_url                   = var.s3_url
  s3_access_key            = var.s3_access_key
  s3_secret_key            = var.s3_secret_key
  object_store_bucket_name = var.object_store_bucket_name
  s3_boolean               = "true"
  storage_reader_key_name  = var.relative_path_to_gcs_key
}

output "nsx-datacenter-pasword" {
  value = module.nsx-dc.nsx_password
}

output "nsx-datacenter-cli-password" {
  value = module.nsx-dc.nsx_cli_password
}

provider "nsxt" {
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

