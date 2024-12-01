#!/bin/bash

# Enable debugging output
set -x

# Variables
CLI_JAR="jenkins-cli.jar"
GROOVY_SCRIPT="/tmp/configure-tools.groovy"  # Ensure this is the correct path
JENKINS_URL="http://127.0.0.1:8080"
JENKINS_DIR="/var/lib/jenkins"

# Fetch Jenkins admin password from Google Cloud Secret Manager
jenkins_admin_password=$(gcloud secrets versions access latest --secret="jenkins-admin-password")

# Fetch bcrypt hashed password from Google Cloud Secret Manager
admin_password=$(gcloud secrets versions access latest --secret="jenkins-bcrypt-password")

# Check if passwords were fetched successfully
if [[ -z "$jenkins_admin_password" ]]; then
    echo "Error: Failed to fetch Jenkins admin password from Secret Manager."
    exit 1
fi

if [[ -z "$admin_password" ]]; then
    echo "Error: Failed to fetch Jenkins bcrypt password from Secret Manager."
    exit 1
fi

### Function: Wait for Jenkins to be available on port 8080 ###
wait_for_jenkins() {
    while true; do
        echo "Waiting for Jenkins to launch on port [8080]..."
        
        # Check if Jenkins is listening on port 8080
        nc -zv 127.0.0.1 8080
        if [ $? -eq 0 ]; then
            break
        fi
        
        sleep 10
    done

    echo "Jenkins launched successfully"
}

### Function: Configure Jenkins server and install plugins ###
configure_jenkins_server() {
    # Check if Jenkins CLI exists
    if [[ ! -f $JENKINS_DIR/$CLI_JAR ]]; then
        echo "Installing Jenkins CLI..."
        wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $JENKINS_DIR/jenkins-cli.jar
        if [[ $? -ne 0 ]]; then
            echo "Failed to download Jenkins CLI."
            exit 1
        fi
    else
        echo "Jenkins CLI already downloaded."
    fi

    # Check if the Groovy script exists before attempting to run it
    if [[ ! -f $GROOVY_SCRIPT ]]; then
        echo "Error: Groovy script ($GROOVY_SCRIPT) not found."
        exit 1
    fi

    # Run the Groovy script via Jenkins CLI
    echo "Configuring Jenkins tools..."
    java -jar $JENKINS_DIR/$CLI_JAR -s $JENKINS_URL -auth admin:$jenkins_admin_password groovy = < $GROOVY_SCRIPT

    echo "Jenkins tools configured successfully."
}

### Script execution starts here ###
wait_for_jenkins  # Wait for Jenkins to be up
configure_jenkins_server  # Configure Jenkins server and install plugins

echo "All tasks completed successfully."
