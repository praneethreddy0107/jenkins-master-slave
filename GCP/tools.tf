resource "null_resource" "configure_tools" {
  depends_on = [null_resource.tools_install]

  # Establish SSH connection
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.jenkins_master_key.private_key_pem
    host        = coalesce(module.jenkins_master.external_ip, module.jenkins_master.internal_ip)
  }

  # Provision the shell script to the Jenkins server
  provisioner "file" {
    source      = "scripts/configure-tools.sh"
    destination = "/tmp/configure-tools.sh"
  }

  # Provision the Groovy script to the Jenkins server
  provisioner "file" {
    source      = "scripts/configure-tools.groovy"
    destination = "/tmp/configure-tools.groovy"
  }

  # Execute the shell script and the Groovy script on the Jenkins server
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/configure-tools.sh",             # Make shell script executable
      "sudo sh -x /tmp/configure-tools.sh",           # Execute the shell script
    ]
  }
}
