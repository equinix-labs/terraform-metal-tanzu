module "vsphere" {
  source           = "equinix/vsphere/metal"
  version          = "2.1.0"
  auth_token       = ""
  organization_id  = ""
  project_name     = "vmware-packet-project-1"
  s3_boolean       = "true"
  s3_url           = var.s3_url
  s3_bucket_name   = "vmware"
  s3_access_key    = var.s3_access_key
  s3_secret_key    = var.s3_secret_key
  vcenter_iso_name = var.vcenter_iso_name
}
