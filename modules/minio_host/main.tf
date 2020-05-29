variable "plan_node" {}
variable "project_id" {}
variable "facility" {}
variable "minio_access_key" {}
variable "minio_secret_key" {}

resource "packet_device" "minio_host" {
  hostname         = "minio"
  operating_system = "ubuntu_18_04"
  plan             = var.plan_node
  facilities       = [var.facility]
  user_data        = data.template_file.minio.rendered
  tags             = ["minio"]

  billing_cycle = "hourly"
  project_id    = var.project_id
}

data "template_file" "minio" {
  template = file("${path.module}/minio.tpl")

  vars = {
    access_key = var.minio_access_key
    secret_key = var.minio_secret_key
  }
}

output "minio_host_addr" {
  value = "${packet_device.minio_host.network.0.address}"
}