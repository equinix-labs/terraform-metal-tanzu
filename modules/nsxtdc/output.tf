output "nsx_password" {
  value = "${random_string.nsx_password.result}"
}

output "nsx_cli_password" {
  value = "${random_string.nsx_cli_password.result}"
}
