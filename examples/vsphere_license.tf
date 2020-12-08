variable "vsphere_license" {}
variable "vsphere_addon_license" {}
variable "vsphere_enterprise_license" {}

module "vsphere_license" {
  source              = "./modules/vsphere-license"
  vsphere_server      = "vcva.packet.local"
  vsphere_user        = "Administrator@vsphere.local"
  vsphere_password    = random_string.sso_password.result
  license_key         = var.vsphere_license
  product_description = "vSphere 7 Standard"
}

module "vsphere_enterprise_license" {
  source              = "./modules/vsphere-license"
  vsphere_server      = "vcva.packet.local"
  vsphere_user        = "Administrator@vsphere.local"
  vsphere_password    = random_string.sso_password.result
  license_key         = var.vsphere_enterprise_license
  product_description = "vSphere 7 Enterprise"
}

module "vsphere_addon_license" {
  source              = "./modules/vsphere-license"
  vsphere_server      = "vcva.packet.local"
  vsphere_user        = "Administrator@vsphere.local"
  vsphere_password    = random_string.sso_password.result
  license_key         = var.vsphere_addon_license
  product_description = "vSphere 7 Kubernetes Addon"
}
