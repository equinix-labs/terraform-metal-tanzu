module "vsphere" {
  source           = "equinix/vsphere/metal"
  version          = "2.2.0"
  auth_token       = var.auth_token
  organization_id  = var.organization_id
  project_name     = "tanzu-on-metal"
  s3_url           = var.s3_url
  s3_access_key    = var.s3_access_key
  s3_secret_key    = var.s3_secret_key
  vcenter_iso_name = var.vcenter_iso_name
  create_project   = var.create_project
  domain_name      = var.domain_name
}

