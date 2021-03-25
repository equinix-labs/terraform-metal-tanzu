variable "storage_reader_key_name" {}
variable "s3_boolean" {}
variable "s3_url" {}
variable "s3_access_key" {}
variable "s3_secret_key" {}
variable "object_store_bucket_name" {}
variable "nsx_manager_ova_name" {}
variable "nsx_controller_ova_name" {}
variable "nsx_edge_ova_name" {}
variable "nsx_domain_0" {}
variable "router_host" {}
variable "ssh_private_key" {}
variable "vcva_host" {}
variable "vcva_user" {}
variable "vcva_password" {}
variable "ssh_key_name" {
  default = "id_rsa"
}
