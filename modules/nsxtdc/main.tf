variable "gcs_bucket_name" {}
variable "storage_reader_key_name" {}
variable "s3_boolean" {}
variable "s3_url" {}
variable "s3_access_key" {}
variable "s3_secret_key" {}
variable "s3_bucket_name" {}
variable "nsx_manager_ova_name" {}
variable "nsx_controller_ova_name" {}
variable "nsx_edge_ova_name" {}
variable "nsx_domain_0" {}

resource "random_string" "nsx_password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "$!?@*"
}

resource "random_string" "nsx_cli_password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "$!?@*"
}

data "template_file" "download_nsx" {
  template = file("${path.module}/download_nsx.sh")
  vars = {
    gcs_bucket_name         = var.gcs_bucket_name
    storage_reader_key_name = var.storage_reader_key_name
    s3_boolean              = var.s3_boolean
    s3_url                  = var.s3_url
    s3_access_key           = var.s3_access_key
    s3_secret_key           = var.s3_secret_key
    s3_bucket_name          = var.s3_bucket_name
    nsx_manager_ova_name    = var.nsx_manager_ova_name
    nsx_controller_ova_name = var.nsx_controller_ova_name
    nsx_edge_ova_name       = var.nsx_edge_ova_name
    ssh_private_key         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  }
}

resource "null_resource" "download_nsx_ova" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${local.ssh_key_name}")
    host        = packet_device.router.access_public_ipv4
  }

  provisioner "file" {
    content     = data.template_file.download_nsx.rendered
    destination = "/root/download_nsx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root",
      "chmod +x /root/download_nsx.sh",
      "/root/download_nsx.sh"
    ]
  }
}

data "template_file" "prepare_nsx" {
  template = file("${path.module}/prepare_nsx.sh")
  vars = {
    NSX_MANAGER_OVA_FILE    = "/root/${var.nsx_manager_ova_name}"
    NSX_CONTROLLER_OVA_FILE = "/root/${var.nsx_controller_ova_name}"
    NSX_EDGE_OVA_FILE       = "/root/${var.nsx_edge_ova_name}"

    ssh_private_key = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  }
}

resource "null_resource" "prepare_nsx_ova" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${local.ssh_key_name}")
    host        = packet_device.router.access_public_ipv4
  }

  provisioner "file" {
    content     = data.template_file.prepare_nsx.rendered
    destination = "/root/prepare_nsx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root",
      "chmod +x /root/prepare_nsx.sh",
      "/root/prepare_nsx.sh"
    ]
  }
}
