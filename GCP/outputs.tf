# Output the external IP address of the Jenkins master instance
output "jenkins_master_external_ip" {
  description = "External IP address of the Jenkins Master instance."
  value       = coalesce(module.jenkins_master.external_ip, module.jenkins_master.internal_ip)
}

# Output the internal IP address of the Jenkins master instance
output "jenkins_master_internal_ip" {
  description = "Internal IP address of the Jenkins Master instance."
  value       = module.jenkins_master.internal_ip
}

# Output the SSH connection details for the Jenkins master instance
output "jenkins_master_ssh_details" {
  description = "SSH connection details for the Jenkins Master instance."
  value = {
    user         = "ubuntu"
    private_key  = tls_private_key.jenkins_master_key.private_key_pem
    host         = coalesce(module.jenkins_master.external_ip, module.jenkins_master.internal_ip, "")
  }
  sensitive = true  # Mark the output as sensitive
}

# Output the Jenkins URL
output "jenkins_url" {
  description = "The URL of the Jenkins Slave instance"
  value       = "http://${coalesce(module.jenkins_master.external_ip, module.jenkins_master.internal_ip, "")}:8080"
}

# Output the Jenkins username
output "jenkins_username" {
  description = "The Jenkins username for the Slave instance"
  value       = "admin"  # Update this if the username is different
}

# Output the Jenkins password (if applicable)
output "jenkins_password" {
  description = "The password for the Jenkins Slave instance"
  value       = module.jenkins-password.jenkins_password_secret_version  # Replace this with the actual password variable if applicable
  sensitive   = true  # Mark this output as sensitive
}
