output "VPN_Endpoint" {
  value = module.vsphere.metal_device.router.access_public_ipv4
}

output "VPN_PSK" {
  value = module.vsphere.random_string.ipsec_psk.result
}

output "VPN_Pasword" {
  value = module.vsphere.random_string.vpn_pass.result
}

output "vCenter_FQDN" {
  value = "vcva.metal.local"
}

output "vCenter_Username" {
  value = "Administrator@vsphere.local"
}

output "vCenter_Password" {
  value = random_string.sso_password.result
}

output "vCenter_Appliance_Root_Password" {
  value = random_string.vcenter_password.result
}