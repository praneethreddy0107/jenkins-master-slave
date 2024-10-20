#!/bin/bash
# Update system packages
sudo apt-get update

# =================== Install Java 17 =====================
sudo apt-get install -y openjdk-17-jdk
# Verify installation
java -version


# Add the new Jenkins GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository to the sources list
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the package list to include Jenkins packages
sudo apt-get update

# Install Jenkins
sudo apt-get install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins
 # Install netcat and xmlstarlet on Ubuntu
sudo apt-get install -y netcat
sudo apt-get install -y xmlstarlet

sudo apt-get install -y curl
sudo apt-get install -y wget

# Add SSH private key for Jenkins use
echo '${tls_private_key.jenkins_master_key.private_key_pem}' > /home/ubuntu/.ssh/id_rsa
sudo chmod 600 /home/ubuntu/.ssh/id_rsa
# Verify SSH permissions
ls -la  /home/ubuntu/.ssh