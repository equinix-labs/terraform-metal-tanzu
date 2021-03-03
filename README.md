[![Equinix Metal Website](https://img.shields.io/badge/Website%3A-Metal.Equinix.com-blue)](http://metal.equinix.com) [![Slack Status](https://slack.equinixmetal.com/badge.svg)](https://slack.equinixmetal.com/) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) ![](https://img.shields.io/badge/Stability-Experimental-red.svg) [![Build Status](https://cloud.drone.io/api/badges/packet-labs/packet-tanzu-tf/status.svg)](https://cloud.drone.io/packet-labs/packet-tanzu-tf)

# VMware Tanzu Installation on Equinix Metal with Terraform
These files will allow you to use [Terraform](http://terraform.io) to deploy [VMware Tanzu](https://tanzu.io) on [Equinix Metal's Bare Metal Cloud offering](https://metal.equinix.com/product/). 

Terraform will create a Equinix Metal project complete with a linux machine for routing, a vSphere cluster installed on minimum 3 ESXi hosts with vSAN storage, and a VMware Tanzu supervisor cluster. You can use an existing Equinix Metal Project, check this [section](#use-an-existing-equinix-metal-project) for instructions.

Users are responsible for providing their own VMware vSphere iso, SDK, Equinix Metal account, and upgraded vSphere Enterprise Plus license as described in this readme.

This repository is [Experimental](https://github.com/packethost/standards/blob/master/experimental-statement.md) meaning that it's based on untested ideas or techniques and not yet established or finalized or involves a radically new and innovative style! This means that support is best effort (at best!) and we strongly encourage you to NOT use this in production.

## Prerequisites
To use these Terraform files, you need to have the following Prerequisites:
* A Equinix Metal org-id and [API key](https://metal.equinix.com/developers/api/)
* **If you are new to Equinix Metal**
  * You will need to request an "Entitlement Increase".  You will need to work with Equinix Metal Support via either:
    * Use the ![Equinix Metal Website](https://img.shields.io/badge/Chat%20Now%20%28%3F%29-blue) at the bottom left of the Equinix Metal Web UI
      * OR
    * E-Mail support@equinixmetal.com
  * Your message across one of these mediums should be:
    * I am working with the Tanzu Terrafom deployment (github.com/packet-labs/packet-tanzu-tf). I need an entitlement increase to allow the creation of five or more vLans. Can you please assist?
* [VMware vCenter Server 6.7U3](https://my.vmware.com/group/vmware/details?downloadGroup=VC67U3B&productId=742&rPId=40665) - VMware vCenter Server Appliance ISO obtained from VMware
* [VMware vSAN Management SDK 6.7U3](https://my.vmware.com/group/vmware/details?downloadGroup=VSAN-MGMT-SDK67U3&productId=734) - Virtual SAN Management SDK for Python, also from VMware

If you do not use the NSX-T module in this project, and wish to install it manually:

* [VMware NSX-T Virtual Appliance](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.0/installation/GUID-A65FE3DD-C4F1-47EC-B952-DEDF1A3DD0CF.html) must be installed, and you must (after installation of vSphere has completed) a license for NSX-T Datacenter Advanced must be applied. All other license upgrades are handled via Terraform. 
 
## Associated Equinix Metal Costs
The default variables make use of 4 [c2.medium.x86](https://metal.equinix.com/product/servers/) servers. These servers are $1 per hour list price (resulting in a total solution price of roughly $4 per hour).

You can also deploy just 2 [c2.medium.x86](https://metal.equinix.com/product/servers/) servers for $2 per hour instead.


## Install Terraform 
Terraform is just a single binary.  Visit their [download page](https://www.terraform.io/downloads.html), choose your operating system, make the binary executable, and move it into your path. 
 
Here is an example for **macOS**: 
```bash 
curl -LO https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_darwin_amd64.zip 
unzip terraform_0.12.18_darwin_amd64.zip 
chmod +x terraform 
sudo mv terraform /usr/local/bin/ 
``` 
 
## Initialize Terraform 
Terraform uses modules to deploy infrastructure. In order to initialize the modules your simply run: `terraform init`. This should download five modules into a hidden directory `.terraform` 

## Using an S3 compatible object store

You have the option to use an S3 compatible object store in place of GCS in order to download *closed source* packages such as *vCenter* and the *vSan SDK*. [Minio](http://minio.io) an open source object store, works great for this.

You will need to layout the S3 structure to look like this:
``` 
https://s3.example.com: 
    | 
    |__ vmware 
        | 
        |__ VMware-VCSA-all-6.7.0-14367737.iso
        | 
        |__ vsanapiutils.py
        | 
        |__ vsanmgmtObjects.py
``` 
These files can be downloaded from [My VMware](http://my.vmware.com).
Once logged in to "My VMware" the download links are as follows:
* [VMware vCenter Server 6.7U3](https://my.vmware.com/group/vmware/details?downloadGroup=VC67U3B&productId=742&rPId=40665) - VVMware vCenter Server Appliance ISO
* [VMware vSAN Management SDK 6.7U3](https://my.vmware.com/group/vmware/details?downloadGroup=VSAN-MGMT-SDK67U3&productId=734) - Virtual SAN Management SDK for Python
 
You will need to find the two individual Python files in the vSAN SDK zip file and place them in the S3 bucket as shown above.

For the cluster build to use the S3 option you'll need to change your variable file by adding the `s3_boolean = "true"` and including the `s3_url`, `s3_bucket_name`, `s3_access_key`, `s3_secret_key` in place of the gcs variables.

Here is the create variable file command again, modified for S3:
```bash 
cat <<EOF >terraform.tfvars 
auth_token = "" 
organization_id = "" 
project_name = "vmware-metal-project-1"
s3_boolean = "true"
s3_url = "https://s3.example.com" 
s3_bucket_name = "vmware" 
s3_access_key = "" 
s3_secret_key = "" 
vcenter_iso_name = "VMware-VCSA-all-6.7.0-XXXXXXX.iso" 
EOF 
```  

If you do not have a Minio or other S3 compatible object store available, the [`equinix/distributed-minio` Terraform module](https://registry.terraform.io/modules/equinix/distributed-minio/metal/latest) can be used to create a MinIO, S3-compatible object-store for use with this project-- you can use the outputs from this module to find the `s3_access_key`, `s3_secret_key`, and `s3_url` before proceeding to upload the ISOs as shown above.


## Modify your variables 
There are many variables which can be set to customize your install within `00-vars.tf`. The default variables to bring up a 3 node vSphere cluster and Linux router using Equinix Metal's [c2.medium.x86](https://metal.equinix.com/product/servers/). Change each default variable at your own risk. 

There are some variables you must set with a terraform.tfvars files. You need to set `auth_token` & `organization_id` to connect to Equinix Metal and the `project_name` which will be created in Equinix Metal. You need to provide the vCenter ISO file name as `vcenter_iso_name`. 
 
Here is a quick command plus sample values to start file for you (make sure you adjust the variables to match your environment, pay specail attention that the `vcenter_iso_name` matches whats in your bucket): 
```bash 
cat <<EOF >terraform.tfvars 
auth_token = "cefa5c94-e8ee-4577-bff8-1d1edca93ed8" 
organization_id = "42259e34-d300-48b3-b3e1-d5165cd14169" 
project_name = "tanzu-metal-project-1"
vcenter_iso_name = "VMware-VCSA-all-6.7.0-XXXXXXX.iso" 
EOF 
``` 
 
## Deploy the Equinix Metal vSphere cluster

In `main.tf`, we are importing the [vSphere Terraform module](https://registry.terraform.io/modules/equinix/vsphere/metal/latest?tab=inputs) where you'll see the above are imported, and on the registry page, you can see additional options for deploying vSphere. 

You can instantiate this module (and use for the rest of the examples) using a plan like:

```
module "vsphere" {
  source           = "equinix/vsphere/metal"
  version          = "2.1.0"
  auth_token       = var.auth_token
  organization_id  = var.organization_id
  project_name     = "tanzu-on-metal"
  s3_url           = var.s3_url
  s3_access_key    = var.s3_access_key
  s3_secret_key    = var.s3_secret_key
  vcenter_iso_name = var.vcenter_iso_name
  create_project   = var.create_project
  domain_name      = var.domain_name
}
```

```bash 
terraform apply -target=module.vsphere`
``` 
If you used something like the distributed-minio module to deploy your object storage, you can set values for things like `s3_access_key` in that module instance to `module.distributed-minio.s3_access_key` etc.

This should end with output similar to this: 
``` 
Apply complete! Resources: 50 added, 0 changed, 0 destroyed. 
 
Outputs: 

SSH_Key_Location = An SSH Key was created for this environment, it is saved at ~/.ssh/project_2-20200331215342-key
VPN_Endpoint = 139.178.85.91
VPN_PSK = @1!64v7$PLuIIir9TPIJ
VPN_Pasword = n3$xi@S*ZFgUbB5k
VPN_User = vm_admin
vCenter_Appliance_Root_Password = *XjryDXx*P8Y3c1$
vCenter_FQDN = vcva.metal.local
vCenter_Password = 3@Uj7sor7v3I!4eo
```

The above Outputs will be used later for setting up the VPN.
You can copy/paste them to a file now,
or get the values later from the file `terraform.tfstate`
which should have been automatically generated as a side-effect of the "terraform apply" command.

## vSphere License Management

**Note:** you will need to be connected to the VPN configured with vSphere above in order to manage the cluster license and to access vCenter and apply the license module. Please connect to the VPN before applying this module

The `vsphere-license` module can be used to apply your [vSphere 7 Enterprise Plus license](https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-kubernetes/GUID-9A190942-BDB1-4A19-BA09-728820A716F2.html) and other licenses required for this project's features:

```bash
cp examples/vsphere_license.example license.tf
```
or import the submodules:

```
module "vsphere_license" {
  source              = "equinix/tanzu/metal/vsphere-license"
  vsphere_server      = module.vsphere.vsphere_fqdn
  vsphere_user        = module.vsphere.vsphere_username
  vsphere_password    = module.vsphere.vsphere_root_password
  license_key         = var.vsphere_license
  product_description = "vSphere 7 Standard"
}

module "vsphere_enterprise_license" {
  source              = "equinix/tanzu/metal/vsphere-license"
  vsphere_server      = module.vsphere.vsphere_fqdn
  vsphere_user        = module.vsphere.vsphere_username
  vsphere_password    = module.vsphere.vsphere_root_password
  license_key         = var.vsphere_enterprise_license
  product_description = "vSphere 7 Enterprise"
}

module "vsphere_addon_license" {
  source              = "equinix/tanzu/metal/vsphere-license"
  vsphere_server      = module.vsphere.vsphere_fqdn
  vsphere_user        = module.vsphere.vsphere_username
  vsphere_password    = module.vsphere.vsphere_root_password
  license_key         = var.vsphere_addon_license
  product_description = "vSphere 7 Kubernetes Addon"
}
```

terraform apply -target=module.vpshere_license
terraform apply -target=module.vsphere_addon_license
terraform apply -target=module.vsphere_enterprise_license
```
and you will be prompted for your license keys, or define the following in your `terraform.tfvars`:

```
vsphere_addon_license      = "XXXX-XXXX-XXXX-XXXX-XXXX" #Addon for Kubernetes
vsphere_enterprise_license = "XXXX-XXXX-XXXX-XXXX-XXXX" #vSphere Enterprise 7
vsphere_license            = "XXXX-XXXX-XXXX-XXXX-XXXX" #vSphere Standard
```

At present, the VMware NSX Terraform provider does not have the capability to apply licenses for the NSX-T product, which will also require a Datacenter Advanced license in order to use Tanzu, which can be added via the NSX UI, or [using the NSX API](https://www.vmware.com/support/nsxt/doc/nsxt_20_api.html#Methods.UpdateLicense).

## Deploying NSX Datacenter

**Note** the NSX module requires additional VMware appliances. [Download your appliances from your VMware portal](https://my.vmware.com/en/group/vmware/downloads/), and as you did with the vSphere ISO, add them to your Object Storage, and update the following variables in your `tfvars` before proceeding:

```go
nsx_manager_ova_name = ""
nsx_controller_ova_name = ""
nsx_edge_ova_name = ""
nsx_domain_0 = "" 
```

Deploying the NSX Manager appliance via Terraform module is as follows:

```bash
cp examples/nsx_tf.example nsx_manager.tf
```
or import the submodule:

```
module "nsx-dc" {
  source      = "equinix/tanzu/metal/nsxtdc"
  router_host = module.vsphere.bastion_ip

  ssh_private_key         = chomp(module.vsphere.tls_private_key.ssh_key_pair.private_key_pem)
  nsx_manager_ova_name    = var.nsx_manager_ova_name
  nsx_controller_ova_name = var.nsx_controller_ova_name
  nsx_edge_ova_name       = var.nsx_edge_ova_name
  nsx_domain_0            = var.nsx_domain_0

  nsx_license = var.nsx_license

  vcva_host     = module.vsphere.vsphere_fqdn
  vcva_user     = module.vsphere.vsphere_username
  vcva_password = module.vsphere.vsphere_root_password
  # Using S3 options as you did for vSphere
  s3_boolean     = var.s3_boolean
  s3_url         = var.s3_url
  s3_access_key  = var.s3_access_key
  s3_secret_key  = var.s3_secret_key
  s3_bucket_name = var.s3_bucket_name
}
```
and applying:

```
terraform apply -target=module.nsxt
```

and then use this submodule's outputs to configure NSX to your specification:

```
provider "nsxt" {
  host                  = "" #This value will be in vSphere after the above module deploys.
  username              = "admin"
  password              = module.nsx-dc.nsx_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
  license_keys          = [var.nsx_license]
}
```

Unlike the licenses for the other VMware products, the Terraform provider for NSX does not currently support applying a license, a license for NSX-T Datacenter Advanced must be applied after this module is installed. This can be done in the NSX manager UI, or via [the NSX API](https://www.vmware.com/support/nsxt/doc/nsxt_20_api.html#Methods.UpdateLicense).

## Deploying Kubernetes

Once the upgrades licenses are applied, you can, either, [create a supervisor namespace and cluster from the UI](https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-kubernetes/GUID-177C23C4-ED81-4ADD-89A2-61654C18201B.html) in vSphere, or use the bootstrapping module for a basic cluster:

```bash
terraform plan
terraform apply
```
from the root module, and complete the supervisor cluster spec configuration (i.e. ranges for ingress, egress, storage policy IDs, etc.)

## Size of the vSphere Cluster
The code supports deploying a single ESXi server or a 3+ node vSAN cluster. Default settings are for 3 ESXi nodes with vSAN.

When a single ESXi server is deployed, the datastore is extended to use all available disks on the server. The linux router is still deployed as a separate system.

To do a single ESXi server deployment, set the following variables in your `terraform.tfvars` file:

```bash
esxi_host_count             = 1
```
This has been tested with the c2.medium.x86. It may work with other systems as well, but it has not been fully tested.
We have not tested the maximum vSAN cluster size. Cluster size of 2 is not supported.


## Connect to the Environment via VPN
By connecting via VPN, you will be able to access vCenter plus the admin workstation, cluster VMs, and any services exposed via the seesaw load balancers.

There is an L2TP IPsec VPN setup. There is an L2TP IPsec VPN client for every platform. You'll need to reference your operating system's documentation on how to connect to an L2TP IPsec VPN. 

[MAC how to configure L2TP IPsec VPN](https://support.apple.com/guide/mac-help/set-up-a-vpn-connection-on-mac-mchlp2963/mac)

NOTE- On a mac, for manual VPN setup use the values from Outputs (or from the generated file `terraform.tfstate`):
* "Server Address" = `VPN_Endpoint`
* "Account Name" = `VPN_User`
* "User Authentication: Password" = `VPN_Password`
* "Machine Authentication: Shared Secret" = `VPN_PSK`

[Chromebook how to configure LT2P IPsec VPN](https://support.google.com/chromebook/answer/1282338?hl=en)

Make sure to enable all traffic to use the VPN (aka do not enable split tunneling) on your L2TP client.
NOTE- On a mac, this option is under the "Advanced..." dialog when your VPN is selected (under System Preferences > Network Settings).

Some corporate networks block outbound L2TP traffic. If you are experiencing issues connecting, you may try a guest network or personal hotspot.

Windows 10 is known to be very finicky with L2TP Ipsec VPN. If you are on a Windows 10 client and experience issues getting VPN to work, consider using OpenVPN instead. These [instructions](https://www.cyberciti.biz/faq/ubuntu-18-04-lts-set-up-openvpn-server-in-5-minutes/) may help setting up OpenVPN on the edge-gateway. 

## Connect to the clusters
You will need to ssh into the router/gateway and from there ssh into the admin workstation where the kubeconfig files of your clusters are located. NOTE- This can be done with or without establishing the VPN first.

```
ssh -i ~/.ssh/<private-ssh-key-created-by-project> root@VPN_Endpoint
```

## Connect to the vCenter
Connecting to the vCenter requires that the VPN be established. Once the VPN is connected, launch a browser to https://vcva.metal.local/ui.
You’ll need to accept the self-signed certificate, and then enter the
`vCenter_Username` and `vCenter_Password`
provided in the Outputs of the run of "terraform apply"
(or alternatively from the generated file `terraform.tfstate`).
NOTE- use the `vCenter_Password` and not the `vCenter_Appliance_Root_Password`.
NOTE- on a mac, you may find that the chrome browser will not allow the connection.
If so, try using firefox.

## Exposing k8s services
Currently services can be exposed on the bundled seesaw load balancer(s) on VIPs
within the VM Private Network (172.16.3.0/24 by default). By default we exclude
the last 98 usable IPs of the 172.16.3.0/24 subnet from the DHCP range--
172.16.3.156-172.16.3.254. You can
change this number by adjusting the `reserved_ip_count` field in the VM Private
Network json in `00-vars.tf`. 

At this point services are not exposed to the public internet--you must connect via VPN to access the VIPs and services. One could adjust
iptables on the edge-gateway to forward ports/IPs to VIP.

## Cleaning the environment
To clean up a created environment (or a failed one), run `terraform destroy --auto-approve`.

If this does not work for some reason, you can manually delete each of the resources created in Equinix Metal (including the project) and then delete your terraform state file, `rm -f terraform.tfstate`.

## Use an existing Equinix Metal project
If you have an existing Equinix Metal project you can use it assuming the project has at least 5 available vlans, Equinix Metal project has a limit of 12 Vlans and this setup uses 5 of them.

Get your Project ID, navigate to the Project from the console.equinix.com console and click on PROJECT SETTINGS, copy the PROJECT ID.

add the following variables to your terraform.tfvars

```
create_project                    = false
project_id                        = "YOUR-PROJECT-ID"
```

## Troubleshooting
Some common issues and fixes.

### Error: The specified project contains insufficient public IPv4 space to complete the request. Please e-mail help@equinixmetal.com.

Should be resolved in https://github.com/packet-labs/google-anthos/commit/f6668b1359683eb5124d6ab66457f3680072651a

Due to recent changes to the Equinix Metal API, new organizations may be unable to use the Terraform to build ESXi servers. Equinix Metal is aware of the issue and is planning some fixes. In the meantime, if you hit this issue, email help@equinixmetal.com and request that your organization be white listed to deploy ESXi servers with the API. You should reference this project (https://github.com/packet-labs/vmware-tanzu) in your email.

### Error: POST https://api.equinix.com/metal/v1/ports/e2385919-fd4c-410d-b71c-568d7a517896/disbond:

At times the Equinix Metal API fails to recognize the ESXi host can be enabled for Layer 2 networking (more accurately Mixed/hybrid mode). The terraform will exit and you'll see
```bash
Error: POST https://api.equinix.com/metal/v1/ports/e2385919-fd4c-410d-b71c-568d7a517896/disbond: 422 This device is not enabled for Layer 2. Please contact support for more details. 

  on 04-esx-hosts.tf line 1, in resource "metal_device" "esxi_hosts":
   1: resource "metal_device" "esxi_hosts" {
```

If this happens, you can issue `terraform apply --auto-approve` again and the problematic ESXi host(s) should be deleted and recreated again properly. Or you can perform `terraform destroy --auto-approve` and start over again.

### null_resource.download_vcenter_iso (remote-exec): E: Could not get lock /var/lib/dpkg/lock - open (11: Resource temporarily unavailable)

Occasionally the Ubuntu automatic unattended upgrades will run at an unfortunate time and lock apt while the script is attempting to run. 

Should this happen, the best resolution is to clean up your deployment and try again. 

### SSH_AUTH_SOCK: dial unix /tmp/ssh-vPixj98asT/agent.11502: connect: no such file or directory

A failed deployment which results in the following output:
```bash
Error: Error connecting to SSH_AUTH_SOCK: dial unix /tmp/ssh-vPixj98asT/agent.11502: connect: no such file or directory



Error: Error connecting to SSH_AUTH_SOCK: dial unix /tmp/ssh-vPixj98asT/agent.11502: connect: no such file or directory



Error: Error connecting to SSH_AUTH_SOCK: dial unix /tmp/ssh-vPixj98asT/agent.11502: connect: no such file or directory



Error: Error connecting to SSH_AUTH_SOCK: dial unix /tmp/ssh-vPixj98asT/agent.11502: connect: no such file or directory
```

This could be because you are using a terminal emulation such as `screen`or `tmux` and the SSH agent is not running. May be corrected by running the command `ssh-agents bash` prior to running the `terraform apply --auto-approve` command.

