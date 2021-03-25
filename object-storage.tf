
module "distributed-minio" {
  source     = "equinix/distributed-minio/metal"
  version    = "0.1.0"
  auth_token = var.metal_auth_token
  project_id = var.metal_project_id
}
