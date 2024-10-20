module "firewall-rules" {
    source = "./modules/nat-firewall"
    network_name = var.network_interfaces[0].network
    project_id = var.project_id
    rules = var.rules
  

 }


module "jenkins-password" {
  source = "./modules/secret-manager"
  name        = "jenkins-admin-password"
  secret_data = var.jenkins_password
  project_id = var.project_id
}