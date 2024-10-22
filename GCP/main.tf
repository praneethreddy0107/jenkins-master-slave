module "firewall-rules" {
    source = "./modules/nat-firewall"
    network_name = var.network_interfaces[0].network
    project_id = var.project_id
    rules = var.rules
  

 }
# Bcrypt hashed password (ensure this is already hashed)

module "jenkins-bcrypt-password" {
  source = "./modules/secret-manager"
  name        = "jenkins-bcrypt-password"
  secret_data = var.jenkins_bcrypt_password
  project_id = var.project_id
}

module "jenkins-password" {
  source = "./modules/secret-manager"
  name        = "jenkins-admin-password"
  secret_data = var.jenkins_password
  project_id = var.project_id
}