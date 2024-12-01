pipeline {
    agent any
    stages {
        stage('Check JDK') {
            steps {
                script {
                    try {
                        echo "Checking JDK version..."
                        def jdkVersion = sh(script: 'java -version', returnStdout: true, returnStatus: true)
                        if (jdkVersion != 0) {
                            error "JDK is not correctly installed."
                        } else {
                            echo "JDK is correctly configured."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        echo "Error checking JDK: ${e.message}"
                    }
                }
            }
        }
        
        stage('Check Maven') {
            steps {
                script {
                    try {
                        echo "Checking Maven version..."
                        def mavenVersion = sh(script: 'mvn -v', returnStdout: true, returnStatus: true)
                        if (mavenVersion != 0) {
                            error "Maven is not correctly installed."
                        } else {
                            echo "Maven is correctly configured."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        echo "Error checking Maven: ${e.message}"
                    }
                }
            }
        }
        
        stage('Check Git') {
            steps {
                script {
                    try {
                        echo "Checking Git version..."
                        def gitVersion = sh(script: 'git --version', returnStdout: true, returnStatus: true)
                        if (gitVersion != 0) {
                            error "Git is not correctly installed."
                        } else {
                            echo "Git is correctly configured."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        echo "Error checking Git: ${e.message}"
                    }
                }
            }
        }

        stage('Check Docker') {
            steps {
                script {
                    try {
                        echo "Checking Docker version..."
                        def dockerVersion = sh(script: 'docker --version', returnStdout: true, returnStatus: true)
                        if (dockerVersion != 0) {
                            error "Docker is not correctly installed."
                        } else {
                            echo "Docker is correctly configured."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        echo "Error checking Docker: ${e.message}"
                    }
                }
            }
        }

        stage('Check Helm') {
            steps {
                script {
                    try {
                        echo "Checking Helm version..."
                        def helmVersion = sh(script: 'helm version', returnStdout: true, returnStatus: true)
                        if (helmVersion != 0) {
                            error "Helm is not correctly installed."
                        } else {
                            echo "Helm is correctly configured."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        echo "Error checking Helm: ${e.message}"
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Check tools job completed."
        }
        success {
            echo "All tools are configured properly."
        }
        failure {
            echo "One or more tools failed to configure properly."
        }
    }
}
