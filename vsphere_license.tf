module "vsphere_license" {
  source              = "./modules/vsphere-license"
  vsphere_server      = module.vsphere.vcenter_fqdn
  vsphere_user        = module.vsphere.vcenter_username
  vsphere_password    = module.vsphere.vcenter_password
  license_key         = var.vsphere_license
  product_description = "vSphere 7 Standard"
}

module "vsphere_enterprise_license" {
  source              = "./modules/vsphere-license"
  vsphere_server      = module.vsphere.vcenter_fqdn
  vsphere_user        = module.vsphere.vcenter_username
  vsphere_password    = module.vsphere.vcenter_password
  license_key         = var.vsphere_enterprise_license
  product_description = "vSphere 7 Enterprise"
}

module "vsphere_addon_license" {
  source              = "./modules/vsphere-license"
  vsphere_server      = module.vsphere.vcenter_fqdn
  vsphere_user        = module.vsphere.vcenter_username
  vsphere_password    = module.vsphere.vcenter_password
  license_key         = var.vsphere_addon_license
  product_description = "vSphere 7 Kubernetes Addon"
}
