data "template_file" "esx_host_networking" {
  template = file("${path.module}/templates/configure_supervisor_cluster.py")
  vars = {
    host            = var.vcenter_host
    user            = var.vcenter_admin
    password        = var.vcenter_password
    clustername     = var.cluster_name
    mastervmnetwork = var.cp_vm_network
    startingip      = var.starting_ip
    mastersm        = var.cp_subnet_mask
    gatewayip       = var.cp_gateway_ip
    dnsserver       = var.dns_server
    ntpserver       = var.ntp_server
    storagepolicy   = var.storage_policy_name
    egressaddress   = var.egress_starting_ip
    ingressaddress  = var.ingress_starting_ip
  }
}

resource "null_resource" "supervisor_cluster_config" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = var.router_address
  }

  provisioner "file" {
    content     = data.template_file.esx_host_networking.rendered
    destination = "/root/configure_supervisor_cluster.py"
  }
}

resource "null_resource" "apply_supervisor_cluster_config" {

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = var.router_address
  }

  provisioner "remote-exec" {
    inline     = ["python3 /root/configure_supervisor_cluster.py"]
    on_failure = continue
  }
}
