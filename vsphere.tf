module "vsphere" {
  source                   = "equinix/vsphere/metal"
  version                  = "3.0.0"
  auth_token               = var.metal_auth_token
  organization_id          = var.metal_organization_id
  project_id               = var.metal_project_id
  s3_url                   = var.s3_url
  s3_access_key            = var.s3_access_key
  s3_secret_key            = var.s3_secret_key
  s3_version               = var.s3_version
  object_store_bucket_name = var.object_store_bucket_name
  vcenter_iso_name         = var.vcenter_iso_name
  create_project           = false # var.metal_create_project
  esxi_host_count          = var.esxi_host_count
  esxi_size                = var.esxi_size
  router_size              = var.router_size
  metro                    = var.metro
  vmware_os                = var.vmware_os
}


provider "ssh" {}

data "ssh_tunnel" "vsphere" {
  depends_on = [module.vsphere]
  user       = "root"
  auth {
    private_key {
      content = file(pathexpand(module.vsphere.ssh_key_path))
    }
  }
  server {
    host = module.vsphere.bastion_host
    port = 22
  }
  remote {
    host = module.vsphere.vcenter_fqdn # also vcenter_ip
    port = 443
  }
}

provider "vsphere" {
  user           = module.vsphere.vcenter_username
  password       = module.vsphere.vcenter_password
  #vsphere_server       = "${data.ssh_tunnel.vsphere.local.0.host}:${data.ssh_tunnel.vsphere.local.0.port}"
  vsphere_server       = data.ssh_tunnel.vsphere.local.0.address
  allow_unverified_ssl = true
}
output "goo" {
  value = jsonencode(data.ssh_tunnel.vsphere.local.0.address)
}
data "ssh_tunnel_close" "vsphere" {
  depends_on = [
    data.ssh_tunnel.vsphere,
    module.vsphere_license,
    module.vsphere_enterprise_license,
    module.vsphere_addon_license,
  ]
}


