resource "random_string" "minio_access_key" {
  length  = 20
  special = false
  upper   = true
}

resource "random_string" "minio_secret_key_a" {
  length      = 13
  special     = false
  upper       = false
  min_lower   = 6
  min_numeric = 6
}

resource "random_string" "minio_secret_key_b" {
  length  = 7
  special = false
  upper   = true
}

resource "random_string" "minio_secret_key_c" {
  length  = 18
  special = false
  upper   = false
}

output "minio_access_key" {
  value = "${random_string.minio_access_key.result}"
}

output "minio_secret_key" {
  value = "${random_string.minio_secret_key_a.result}/${random_string.minio_secret_key_b.result}/${random_string.minio_secret_key_c.result}"
}
