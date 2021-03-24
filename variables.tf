variable "nsdomain" {
  default     = "metal.local"
  description = "NSX Domain"
}
variable "cluster_name" {
  default     = "metal-supervisor-tf"
  description = "Supervisor Cluster Name"
}
variable "namespace" {
  default     = "Default"
  description = "Cluster Namespace"
}
variable "storagepolicy" {
  description = "Storage Policy Name configured in vSAN"
}
variable "storagelimit" {}

variable "cp_vm_network" {
  description = "VM Network CIDR"
}

variable "cp_subnet_mask" {
  description = "VM Network Subnet Mask"
}

variable "cp_gateway_ip" {
  description = "VM Network Gateway Address"
}

variable "starting_ip" {
  description = "VM Network Range Starting IP for Cluster Services"
}

variable "dns_server" {
  description = "DNS Server (Either configured in NSX or external)"
}
variable "ntp_server" {
  description = "NTP configured in VMWare or external"
}
variable "storage_policy_name" {
  description = "Storage Policy Name"
}
variable "egress_starting_ip" {
  description = "Your first usable Metal Elastic Subnet address for Egress range"
}
variable "ingress_starting_ip" {
  description = "Your first usable Metal Elastic Subnet address for Ingress range"
}

variable "vsphere_license" {
  description = "Your vSphere license key."
}
variable "vsphere_addon_license" {
  description = "Your vSphere Addon License."
}
variable "vsphere_enterprise_license" {
  description = "Your vSphere Enterprise License."
}

