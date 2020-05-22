module "credentials" {
  source = "./modules/minio_credentials"
}

module "host" {
  source           = "./modules/minio_host"
  plan_node        = var.plan_node
  facility         = var.facility
  project_id       = var.project_id
  minio_access_key = module.minio_credentials.minio_access_key
  minio_secret_key = module.minio_credentials.minio_secret_key
}

output "Minio_Host" {
  value = "\nAdd these values to terraform.tfvars:\n\ts3_url=http://${module.minio_host.minio_host_addr}\n\ts3_access_key=${module.minio_credentials.minio_access_key}\n\ts3_secret_key=${module.minio_credentials.minio_secret_key}\nor run the following commands:\n\texport TF_VAR_s3_url=http://${module.minio_host.minio_host_addr}\n\texport TF_VAR_s3_access_key=${module.minio_credentials.minio_access_key}\n\texport TF_VAR_s3_secret_key=${module.minio_credentials.minio_secret_key}\nthen login to Minio (or using the `mc` client)to create a bucket named 'vmware' and upload the VMWare files listed below to your bucket."
}
