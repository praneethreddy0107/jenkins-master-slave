#!/bin/bash
set -e

# Update system packages
echo "Updating package lists..."
sudo apt-get update

# =================== Install Java 17 =====================
echo "Installing OpenJDK 17..."
sudo apt-get install -y openjdk-17-jdk
java -version

# =================== Install Jenkins =====================
echo "Adding Jenkins GPG key..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list

echo "Updating package list for Jenkins..."
sudo apt-get update
echo "Installing Jenkins..."
sudo apt-get install -y jenkins

echo "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# =================== Install Dependencies =====================
echo "Installing required dependencies..."
sudo apt-get install -y netcat xmlstarlet curl wget

# =================== Wait for Jenkins to Start =====================
echo "Waiting for Jenkins to fully start..."
while ! nc -z localhost 8080; do
  echo "Waiting for Jenkins service to initialize..."
  sleep 5
done
echo "Jenkins is up and running!"

# =================== Setup SSH Key for Jenkins =====================
echo "Adding SSH private key for Jenkins use..."
mkdir -p /home/ubuntu/.ssh
echo '${tls_private_key.jenkins_master_key.private_key_pem}' > /home/ubuntu/.ssh/id_rsa
sudo chmod 600 /home/ubuntu/.ssh/id_rsa
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# Verify SSH setup
ls -la /home/ubuntu/.ssh

echo "Jenkins installation and setup complete!"
