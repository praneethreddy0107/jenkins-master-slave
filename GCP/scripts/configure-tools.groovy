import jenkins.model.*
import hudson.model.*
import hudson.tools.*
import hudson.tasks.Maven
import hudson.plugins.git.GitTool
import hudson.plugins.sonar.SonarRunnerInstallation
import com.nirima.jenkins.plugins.docker.DockerTool

// Get Jenkins instance
def jenkins = Jenkins.instance

// Configure JDK
println("Configuring JDK...")
def jdkDescriptor = jenkins.getDescriptorByType(hudson.model.JDK.DescriptorImpl)
jdkDescriptor.setInstallations(
    new JDK("JDK17", "/usr/lib/jvm/java-17-openjdk-amd64")
)

// Configure Maven
println("Configuring Maven...")
def mavenDescriptor = jenkins.getDescriptorByType(hudson.tasks.Maven.DescriptorImpl)
mavenDescriptor.setInstallations(
    new Maven.MavenInstallation("Maven", "/usr/share/maven", null)
)

// Configure Git
println("Configuring Git...")
def gitDescriptor = jenkins.getDescriptorByType(hudson.plugins.git.GitTool.DescriptorImpl)
gitDescriptor.setInstallations(
    new GitTool("Default", "/usr/bin/git", null)
)

// Configure SonarQube Scanner
println("Configuring SonarQube Scanner...")
def sonarDescriptor = jenkins.getDescriptorByType(hudson.plugins.sonar.SonarRunnerInstallation.DescriptorImpl)
sonarDescriptor.setInstallations(
    new SonarRunnerInstallation("SonarScanner", "/opt/sonar-scanner/bin", null)
)

// Configure Docker
println("Configuring Docker...")
def dockerDescriptor = jenkins.getDescriptorByType(com.nirima.jenkins.plugins.docker.DockerTool.DescriptorImpl)
dockerDescriptor.setInstallations(
    new DockerTool("Default", "/usr/bin/docker")
)

// Save configuration
jenkins.save()
println("Global tools configured successfully!")
