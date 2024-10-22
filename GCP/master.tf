
module "jenkins_master" {
  source           = "./modules/compute-instance"
  can_ip_forward   = var.can_ip_forward
  name             = "${var.name}-master"
  zone             = "${var.zone}-a"
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

}


#===========================================
resource "null_resource" "setup_jenkins" {
  depends_on = [module.jenkins_master]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.jenkins_master_key.private_key_pem
    host        =  coalesce(module.jenkins_master.external_ip,module.jenkins_master.internal_ip)
   # host = module.jenkins_master.external_ip
  }
  provisioner "file" {
    source      = "scripts/install-jenkins.sh"
    destination = "/tmp/install-jenkins.sh"


  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-jenkins.sh",
      "sudo sh -x /tmp/install-jenkins.sh",
    ] # Execute main.sh within the directory


  }
}
# null resource 
resource "null_resource" "install_plugin" {
  depends_on = [module.jenkins_master, null_resource.setup_jenkins,module.jenkins-password,module.jenkins-bcrypt-password]
  connection {
    host        = coalesce(module.jenkins_master.external_ip, module.jenkins_master.internal_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.jenkins_master_key.private_key_pem
    timeout     = "50s"
  }

  provisioner "file" {
    source      = "scripts/get-InitialPassword.sh"
    destination = "/tmp/get-InitialPassword.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/get-InitialPassword.sh",
      "sudo sh -x /tmp/get-InitialPassword.sh",
    ]
  }
}
