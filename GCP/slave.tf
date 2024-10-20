
module "jenkins_slave" {
  source           = "./modules/compute-instance"
  can_ip_forward   = var.can_ip_forward
  name             = "${var.name}-slave"
  zone             = "${var.zone}-b"
  enable_public_ip = var.enable_public_ip
  description      = var.description
  hostname         = var.hostname
  tags             = var.tags
  project_id       = var.project_id
  instance_type    = var.instance_type
  min_cpu_platform = var.min_cpu_platform
  options          = var.options
  enable_display   = var.enable_display
  labels           = var.labels
  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.jenkins_master_key.public_key_openssh}"
  }
  boot_disk  = var.boot_disk
  encryption = var.encryption

  network_attached_interfaces = var.network_attached_interfaces
  network_interfaces          = var.network_interfaces
  confidential_compute        = var.confidential_compute
  service_account             = var.service_account
  shielded_config             = var.shielded_config

metadata_startup_script = data.template_file.userdata_jenkins_worker_linux.rendered
}




data "template_file" "userdata_jenkins_worker_linux" {
  template   = file("scripts/jenkins-node.sh")
  depends_on = [module.jenkins_master, module.firewall-rules, null_resource.install_plugin]

  vars = {
    jenkins_url      = module.jenkins_master.external_ip
    jenkins_username = "admin"
    #jenkins_password = module.jenkins-password.jenkins_password_secret_version
    jenkins_password="password"
    device_name      = "ens4"
    worker_pem       = tls_private_key.jenkins_master_key.private_key_pem
  }
}  