#!/bin/bash

set -e

echo "Starting tool installation..."

# =================== Update and Upgrade System ===================
echo "Updating and upgrading system packages..."
sudo apt update -y 

# =================== Install OpenJDK 17 ===================
echo "Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
echo "Java installed at $JAVA_HOME"

# =================== Install Git ===================
echo "Installing Git..."
sudo apt install -y git
GIT_HOME="$(which git)"
echo "Git installed at $GIT_HOME"

# =================== Install Node.js and npm ===================
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
NODE_HOME="$(which node)"
echo "Node.js installed at $NODE_HOME"

# =================== Install Docker ===================
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $(whoami)
DOCKER_HOME="/usr/bin/docker"
# Add Jenkins user to Docker group
echo "Adding Jenkins user to Docker group..."
sudo usermod -aG docker jenkins

# Restart Docker service to apply group changes
echo "Restarting Docker service..."
sudo systemctl restart docker

echo "Docker installed at $DOCKER_HOME"

# =================== Install Maven ===================
echo "Installing Maven..."
sudo apt install -y maven
MAVEN_HOME="/usr/share/maven"
echo "Maven installed at $MAVEN_HOME"
# # =================== Install Trivy ===================
# echo "Installing Trivy..."
# curl -fsSL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo bash

# # Add Trivy to PATH explicitly for the current session
# TRIVY_HOME="/usr/local/bin/trivy"
# export PATH=$PATH:/usr/local/bin

# # Verify installation
# echo "Verifying Trivy installation..."
# # TRIVY_HOME="$(which trivy)"
# # echo "Trivy installed at $TRIVY_HOME"

# =================== Install Helm ===================
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
HELM_HOME="$(which helm)"
echo "Helm installed at $HELM_HOME"

# =================== Print Installed Tool Versions ===================
echo "Installed tool versions:"
java -version
git --version
npm --version
docker --version
mvn --version
#trivy --version
helm version

# =================== Display Paths for Global Tool Configuration ===================
echo "Global Tool Configuration Paths:"
echo "JDK Path: $JAVA_HOME"
echo "Git Path: $GIT_HOME"
echo "Node.js Path: $NODE_HOME"
echo "Docker Path: $DOCKER_HOME"
echo "Maven Path: $MAVEN_HOME"
#echo "Trivy Path: $TRIVY_HOME"
echo "Helm Path: $HELM_HOME"
sudo systemctl restart jenkins

echo "Tool installation complete. Log out and log back in to apply Docker group changes."
