resource "vsphere_license" "licenseKey" {
  license_key = var.license_key

  labels = {
    # TODO Equinix Metal
    Provider = "Packet"
    Product  = var.product_description
  }

}

#Resource for connecting to the API for non-TF managed resources will be managed here in next release
