#!/bin/bash

# Function to display error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Function to display success message
success_msg() {
    echo "Success: $1"
}

# Install Docker
sudo apt update
sudo apt install docker.io -y || error_exit "Failed to install Docker."

# Create Dockerfile
cat <<EOF | sudo tee Dockerfile > /dev/null
FROM jenkins/jenkins:lts

# Expose ports for Jenkins web UI and agent communication
EXPOSE 8080 50000

# Set up a volume to persist Jenkins data
VOLUME /var/jenkins_home

# Set up the default command to run Jenkins
CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
EOF

# Build Jenkins image
sudo docker build -t my-custom-jenkins . || error_exit "Failed to build Jenkins image."


# Run Jenkins container
#sudo docker run -d --restart always -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_data:/var/jenkins_home --name jenkins my-custom-jenkins || error_exit "Failed to run Jenkins container."
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_data:/var/jenkins_home --name jenkins --restart always jenkins/jenkins:lts || error_exit "Failed to run Jenkins container."
sudo chown -R 1000:1000 /home/ubuntu/jenkins_data
# Find the container ID
CONTAINER_ID=$(sudo docker ps -aqf "name=jenkins")

# Check if the container ID is not empty
if [ -n "$CONTAINER_ID" ]; then
    # Display the logs of the container
    sudo docker logs "$CONTAINER_ID"
else
    echo "Container 'jenkins' is not running or does not exist."
fi

# Install dependencies inside the container
sudo docker exec -u root jenkins apt-get update
sudo docker exec -u root jenkins apt-get install -y wget
sudo docker exec -u root jenkins apt-get install -y nano

# Get container IP address
CONTAINER_IP=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID)

# Download Jenkins CLI JAR file
sudo docker exec -u root jenkins wget "http://$CONTAINER_IP:8080/jnlpJars/jenkins-cli.jar"
#sudo docker exec -u root jenkins wget "http://172.17.0.2:8080/jnlpJars/jenkins-cli.jar"


# Restart Jenkins container
sudo docker restart jenkins || error_exit "Failed to restart Jenkins container."

# Install GitLab plugin using Jenkins CLI
#sudo docker exec -u root jenkins java -jar /jenkins-cli.jar -s http://localhost:8080/ install-plugin gitlab-plugin || error_exit "Failed to install GitLab plugin."
sudo docker exec -u root jenkins java -jar /usr/share/jenkins/jenkins-cli.jar -s http://172.17.0.2:8080/ install-plugin gitlab-plugin || error_exit "Failed to install GitLab plugin."
success_msg "Jenkins setup completed successfully. You can now access Jenkins at http://localhost:8080"


#create credentails. First create credentails.xml file pass the values in that file. then give the command to create the credenatisl.
#before executing this command, make sure xml file is correctly formatted. credentail.xml file have the permissions. i created credential.xml file in (home/ubuntu)




 cat credential.xml 
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
    <scope>GLOBAL</scope>
    <id>Gitlab_id</id>
    <username>saruSaranya</username>
    <password>saruSYAM23</password>
    <description>Gitlab_id</description>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>


sudo docker exec -i jenkins sh -c 'java -jar jenkins-cli.jar -auth saranya:saranya -s http://44.203.130.84:8080/ create-credentials-by-xml system::system::jenkins _ < /dev/stdin' < credential.xml

sudo docker exec -i jenkins java -jar jenkins-cli.jar -s http://44.203.130.84:8080/ enable-plugin gitlab-plugin -restart
s



sudo docker exec -u root jenkins java -jar /jenkins-cli.jar -s http://172.17.0.2:8080/ install-plugin credentials

sudo docker exec -i jenkins java -jar jenkins-cli.jar -s http://44.203.130.84:8080/ enable-plugin credentials -restart

sudo docker exec -i jenkins java -jar /jenkins-cli.jar -s http://172.17.0.2:8080/ install-plugin credentials:1337.v60b_d7b_c7b_c9f

sudo nano new_credential.xml

<com.cloudbees.plugins.credentials.impl.StringCredentialsImpl>
    <scope>GLOBAL</scope>
    <id>GitLab_token</id>
    <description>GitLab_token</description>
    <secret>glpatolkaJLF5QsolPZixYmz9My82</secret>
</com.cloudbees.plugins.credentials.impl.StringCredentialsImpl>


sudo docker exec -i jenkins sh -c 'java -jar jenkins-cli.jar -auth saranya:saranya -s http://18.233.154.201:8080/ create-credentials-by-xml system::system::jenkins _ < /dev/stdin' < new_credential.xml


sudo nano ec2_pemkey.pem
(paste the content)
sudo chmod 777 ec2_pemkey.pem

sudo nano job_config.xml

<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.42">
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig plugin="pipeline-model-definition@1.10.2">
      <dockerLabel></dockerLabel>
      <registry plugin="docker-commons@1.17"/>
      <registryCredentialId></registryCredentialId>
    </org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.90">
    <script>
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Code checkout from the repository'
                git credentialsId: 'Gitlab_id', url: 'https://gitlab.com/practice-group9221502/jenkins-project.git', branch: 'dev'
            }
        }
        
        stage('Transfer HTML File') {
            steps {
                script {
                    // List files to verify the context
                    
                    sh 'ls -a'
                     // Find HTML file
                    def htmlFile = sh(returnStdout: true, script: 'find /var/jenkins_home/workspace/mn-serviceproviders-website -name "*.html"').trim()
                    
                    // Transfer the HTML file to another machine via SSH
                    sh "scp -i /var/jenkins_home/ec2_pemkey.pem \"$htmlFile\" ubuntu@54.162.174.85:/home/ubuntu/"
                

                    
                    
                }
            }
        }
    }
}
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
  <!-- GitLab configuration -->
  <scm class="hudson.plugins.git.GitSCM" plugin="git@4.12.0">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://gitlab.com</url> <!-- GitLab host URL -->
        <credentialsId>glpat-f_5_eV8nnWDV8HTn3CaZ</credentialsId> <!-- Credentials ID for GitLab API token -->
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <!-- Other Git SCM settings -->
  </scm>
</flow-definition>


