

output "external_ip" {
  description = "Instance main interface external IP addresses."
  value =  try(google_compute_instance.instance.network_interface[0].access_config[0].nat_ip, null)
   
}


output "id" {
  description = "Fully qualified instance id."
  value       = try(google_compute_instance.instance.id, null)
}

output "instance" {
  description = "Instance resource."
  sensitive   = true
  value       = try(google_compute_instance.instance, null)
}

output "internal_ip" {
  description = "Instance main interface internal IP address."
  value = try(
    google_compute_instance.instance.network_interface[0].network_ip,
    null
  )
}

output "internal_ips" {
  description = "Instance interfaces internal IP addresses."
  value = [
    for nic in try(google_compute_instance.instance.network_interface, [])
    : nic.network_ip
  ]
}

output "self_link" {
  description = "Instance self links."
  value       = try(google_compute_instance.instance.self_link, null)
}

output "service_account" {
  description = "Service account resource."
  value       = try(google_service_account.service_account[0], null)
}

output "service_account_email" {
  description = "Service account email."
  value       = try(local.service_account.email, null)
}

output "service_account_iam_email" {
  description = "Service account email."
  value = (
    try(local.service_account.email, null) == null
    ? null
    : "serviceAccount:${local.service_account.email}"
  )
}
