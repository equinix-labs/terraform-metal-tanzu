variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "license_key" {}
variable "product_description" {}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

resource "vsphere_license" "licenseKey" {
  license_key = var.license_key

  labels = {
    Provider = "Packet"
    Product  = var.product_description
  }

}

#Resource for connecting to the API for non-TF managed resources will be managed here in next release
