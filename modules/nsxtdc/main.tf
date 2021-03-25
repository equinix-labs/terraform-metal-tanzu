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
  template = file("${path.module}/templates/download_nsx.sh")
  vars = {
    s3_boolean               = var.s3_boolean
    s3_url                   = var.s3_url
    s3_access_key            = var.s3_access_key
    s3_secret_key            = var.s3_secret_key
    object_store_bucket_name = var.object_store_bucket_name
    nsx_manager_ova_name     = var.nsx_manager_ova_name
    nsx_controller_ova_name  = var.nsx_controller_ova_name
    nsx_edge_ova_name        = var.nsx_edge_ova_name
    ssh_private_key          = var.ssh_private_key
  }
}

resource "null_resource" "download_nsx_ova" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = var.router_host
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

data "template_file" "deploy_nsx" {
  template = file("${path.module}/templates/deploy_nsx.sh")
  vars = {
    NSX_MANAGER_OVA_FILE    = "/root/${var.nsx_manager_ova_name}"
    NSX_CONTROLLER_OVA_FILE = "/root/${var.nsx_controller_ova_name}"
    NSX_EDGE_OVA_FILE       = "/root/${var.nsx_edge_ova_name}"
    VCVA_HOST               = var.vcva_host
    VCVA_USER               = var.vcva_user
    VCVA_PASSWORD           = var.vcva_password
    ssh_private_key         = var.ssh_private_key
  }
}

data "template_file" "nsx_template" {
  template = file("${path.module}/templates/nsx-template.json")
  vars = {
    NSX_PASSWD     = random_string.nsx_password.result
    NSX_CLI_PASSWD = random_string.nsx_cli_password.result
    NSX_DOMAIN     = var.nsx_domain_0
  }
}

resource "null_resource" "deploy_nsx_ova" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = var.router_host
  }

  provisioner "file" {
    content     = data.template_file.nsx_template.rendered
    destination = "/root/nsx-manager.json"
  }

  provisioner "file" {
    content     = data.template_file.deploy_nsx.rendered
    destination = "/root/deploy_nsx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root",
      "chmod +x /root/deploy_nsx.sh",
      "sh /root/prepare_nsx.sh"
    ]
  }
}
