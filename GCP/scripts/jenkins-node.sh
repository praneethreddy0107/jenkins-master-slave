#!/bin/bash

set -x

# Update system packages
sudo apt-get update

# =================== Install Java 17 =====================
sudo apt-get install -y openjdk-17-jdk
sudo apt-get install -y netcat
sudo apt-get install -y xmlstarlet
sudo apt-get install -y curl
sudo apt-get install -y wget
sudo apt-get install -y git

# Sleep to allow Jenkins to start properly (if needed)
sudo sleep 120
echo "jenkins password from secret"
echo $jenkins_password

function slave_setup() {
    ret=1
    echo "Jenkins URL: $jenkins_url"
    local jenkins_cli_url="http://${jenkins_url}:8080/jnlpJars/jenkins-cli.jar"
    local slave_jar_url="http://${jenkins_url}:8080/jnlpJars/slave.jar"

    # Download Jenkins CLI jar
    while (( ret != 0 )); do
        sudo wget -O /opt/jenkins-cli.jar "$jenkins_cli_url"
        ret=$?
        echo "jenkins-cli download result: [$ret]"
    done

    ret=1
    # Download Jenkins slave jar
    while (( ret != 0 )); do
        sudo wget -O /opt/slave.jar "$slave_jar_url"
        ret=$?
        echo "slave.jar download result: [$ret]"
    done

    ###################### Jenkins and Slave setup variables ######################
    JENKINS_URL="http://${jenkins_url}:8080"
    USERNAME="${jenkins_username}"
    PASSWORD="${jenkins_password}"

    SLAVE_IP=$(ip -o -4 addr list "${device_name}" | head -n1 | awk '{print $4}' | cut -d/ -f1)
    NODE_NAME=$(echo "jenkins-slave-linux-$SLAVE_IP" | tr '.' '-')
    NODE_SLAVE_HOME="/home/ubuntu"
    EXECUTORS=2
    SSH_PORT=22

    CRED_ID="$NODE_NAME"
    LABELS="linux"
    USERID="ubuntu"

    cd /opt
    # Jenkins command using the CLI
    jenkins_cmd="java -jar /opt/jenkins-cli.jar -s $JENKINS_URL -auth $USERNAME:$PASSWORD"
    
    # Wait for Jenkins to fully load plugins before proceeding
    count=$($jenkins_cmd list-plugins 2>/dev/null | wc -l)
    echo "Number of plugins installed: $count"

    ###################### Create the credentials for the slave machine ######################
    cat > /tmp/cred.xml <<EOF
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.16">
  <scope>GLOBAL</scope>
  <id>$CRED_ID</id>
  <description>Generated via Terraform for $SLAVE_IP</description>
  <username>$USERID</username>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
    <privateKey>${worker_pem}</privateKey>
  </privateKeySource>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF

    # Apply credentials via CLI
    cat /tmp/cred.xml | $jenkins_cmd create-credentials-by-xml system::system::jenkins _

    ###################### Delete existing node if exists ######################
    $jenkins_cmd delete-node $NODE_NAME || echo "Node $NODE_NAME does not exist, creating a new one."

    ###################### Create node configuration ######################
    cat > /tmp/node.xml <<EOF
<slave>
  <name>$NODE_NAME</name>
  <description>Linux Slave</description>
  <remoteFS>$NODE_SLAVE_HOME</remoteFS>
  <numExecutors>$EXECUTORS</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy\$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
    <host>$SLAVE_IP</host>
    <port>$SSH_PORT</port>
    <credentialsId>$CRED_ID</credentialsId>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.KnownHostsFileVerificationStrategy"/>
  </launcher>
  <label>$LABELS</label>
  <nodeProperties/>
  <userId>$USERID</userId>
</slave>
EOF

    sleep 10

    # Apply node configuration via CLI
    cat /tmp/node.xml | $jenkins_cmd create-node $NODE_NAME
}

### Script execution starts here ###
slave_setup

echo "Done"
exit 0
