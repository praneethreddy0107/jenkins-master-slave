#!/bin/bash

set -x  # Enable debugging output



# Fetch Jenkins admin password from GCP Secret Manager
jenkins_admin_password=$(gcloud secrets versions access latest --secret="jenkins-admin-password")
# Bcrypt hashed password (ensure this is already hashed)

admin_password=$(gcloud secrets versions access latest --secret="jenkins-bcrypt-password")

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
        echo "Waiting for Jenkins to launch on port [8080] ..."
        
        # Check if Jenkins is listening on port 8080
        nc -zv 127.0.0.1 8080
        if [ $? -eq 0 ]; then  # Correct comparison syntax
            break
        fi

        sleep 10
    done

    echo "Jenkins launched successfully"
}

### Function: Update Jenkins admin user's password ###
updating_jenkins_master_password() {
    cd /var/lib/jenkins/users/admin* || { echo "Admin user's config directory not found."; exit 1; }
    pwd

   while true; do
    echo "Waiting for Jenkins to generate admin user's config file ..."
    
    # Wait until the config.xml file is generated for the admin user
    if [ -f "./config.xml" ]; then  # Use single bracket for POSIX compliance
        break
    fi

    sleep 10
   done


    echo "Admin config file created."

    
    # Update the password hash in the config.xml for the admin user
    # We use xmlstarlet to edit the XML file in-place
    xmlstarlet ed --inplace -u "/user/properties/hudson.security.HudsonPrivateSecurityRealm_-Details/passwordHash" -v '#jbcrypt:'"$admin_password" config.xml

    # Restart Jenkins to apply the changes
    echo "Restarting Jenkins..."
    systemctl restart jenkins
    sleep 10
    echo "Admin password hash updated and Jenkins restarted."
}

### Function: Configure Jenkins server and install plugins ###
configure_jenkins_server() {
    # Jenkins CLI setup
    echo "Installing Jenkins CLI..."
    wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O /var/lib/jenkins/jenkins-cli.jar
    if [[ $? -ne 0 ]]; then
        echo "Failed to download Jenkins CLI."
        exit 1
    fi

    
   PASSWORD="${jenkins_admin_password}"
    jenkins_dir="/var/lib/jenkins"
    plugins_dir="$jenkins_dir/plugins"

    # Ensure plugins directory exists
    cd $plugins_dir || { echo "Unable to change directory to [$plugins_dir]"; exit 1; }

    # List of plugins to install
    plugin_list="git-client git github-api github-oauth github ssh-slaves workflow-aggregator ws-cleanup"

    # Clean up any existing plugins
    echo "Removing any existing plugins: $plugin_list ..."
    rm -rfv $plugin_list

    # Install each plugin using Jenkins CLI
    for plugin in $plugin_list; do
        echo "Installing plugin [$plugin] ..."
        java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080/ -auth admin:$PASSWORD install-plugin $plugin
    done

    # Safe restart Jenkins after installing the plugins
    echo "Restarting Jenkins after plugin installation..."
    java -jar $jenkins_dir/jenkins-cli.jar -s http://127.0.0.1:8080 -auth admin:$PASSWORD safe-restart
    sleep 10
}

### Script execution starts here ###
wait_for_jenkins  # Wait for Jenkins to be up
updating_jenkins_master_password  # Update Jenkins admin password
configure_jenkins_server  # Configure Jenkins server and install plugins

echo "All tasks completed successfully."
