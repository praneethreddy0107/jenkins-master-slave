# Generate SSH key pair dynamically for Jenkins master to connect to slave
resource "tls_private_key" "jenkins_master_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally (optional)
output "private_key" {
  value     = tls_private_key.jenkins_master_key.private_key_pem
  sensitive = true
}

# Public key for injection into slave
output "public_key" {
  value = tls_private_key.jenkins_master_key.public_key_openssh
}
