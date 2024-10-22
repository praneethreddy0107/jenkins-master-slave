name             = "jenkins"
zone             = "us-central1"
instance_type    = "e2-medium"
enable_public_ip = true

network_interfaces = [{
  network    = "default"
  subnetwork = "default"
}]
boot_disk = {
  initialize_params = {
    image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240927"
    size  = 50
    type  = "pd-ssd"
  }
}
tags = ["jenkins-server", "sonarqube-server"]


service_account = {
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email"
  ]
}
rules = [{
  name        = "allow-jenkins-rules"
  target_tags = ["jenkins-server"]
  direction   = "INGRESS"
  ranges      = ["0.0.0.0/0"]
  allow = [{
    ports    = ["22", "8080"]
    protocol = "tcp"
  }]
  }
  ,
  {
    name        = "allow-sonarube-rules"
    target_tags = ["sonarqube-server"]
    direction   = "INGRESS"
    ranges      = ["0.0.0.0/0"]
    allow = [{
      ports    = ["22", "9000"]
      protocol = "tcp"
    }]
  }

]
#project_id = "" # Update the project_id 
jenkins_password = "password"  #Update the jenkins_password 
jenkins_bcrypt_password = "$2a$10$1LOKaTM.4BdGvju2LsLK4ulAmLrDPr1xbegLVc1RIv9klz5q9TrZO" #Update the jenkins_bcrypt_password 