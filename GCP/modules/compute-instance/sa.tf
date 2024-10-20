resource "google_service_account" "service_account" {
  count        = try(var.service_account.auto_create, null) == true ? 1 : 0
  project      = var.project_id
  account_id   = "tf-vm-${var.name}"
  display_name = "Terraform VM ${var.name}."
}