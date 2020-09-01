data "template_file" "create_namespace" {
  template = file("${path.module}/templates/create_namespace.py")
  vars = {
    host          = var.vcenter_host
    user          = var.vcenter_admin
    password      = var.vcenter_password
    nsuser        = var.nsuser
    nsdomain      = var.nsdomain
    clustername   = var.cluster_name
    namespace     = var.namespace
    storagepolicy = var.storagepolicy
    storagelimit  = var.storagelimit
  }
}

resource "null_resource" "namespace_config" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = var.router_address
  }

  provisioner "file" {
    content     = data.template_file.create_namespace.rendered
    destination = "/root/create_namespace.py"
  }
}

resource "null_resource" "apply_namespace_config" {

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = var.router_address
  }

  provisioner "remote-exec" {
    inline     = ["python3 /root/create_namespace.py"]
    on_failure = continue
  }
}
