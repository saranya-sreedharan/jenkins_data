sudo apt install 
sudo apt install docker.io -y 

sudo nano Dockerfile

FROM jenkins/jenkins:lts

# Expose ports for Jenkins web UI and agent communication
EXPOSE 8080 50000

# Set up a volume to persist Jenkins data
VOLUME /var/jenkins_home

# Set up the default command to run Jenkins
CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]

#buid jenkins image
sudo docker build -t my-custom-jenkins .
#run the image
sudo docker run -d --restart always -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_data:/var/jenkins_home --name jenkins my-custom-jenkins || error_exit "

#find the ip address
CONTAINER_ID=$(sudo docker ps -aqf "name=jenkins")

Check if the container ID is not empty
if [ -n "$CONTAINER_ID" ]; then
    # Display the logs of the container
    sudo docker logs "$CONTAINER_ID"
else
    echo "Container 'jenkins' is not running or does not exist."
fi
#sudo docker exec -it $CONTAINER_ID cat /var/jenkins_home/secrets/initialAdminPassword

# Display success message
success_msg "Jenkins setup completed successfully. You can now access Jenkins at http://localhost:8080"

sudo docker exec -u root jenkins apt-get update

#sudo docker exec -u root jenkins apt install -y jenkins-cli

sudo docker exec -u root jenkins apt-get install -y wget
sudo docker exec -u root jenkins apt-get install -y nano



# Get the container ID
CONTAINER_ID=$(sudo docker ps -aqf "name=jenkins")

# Extract the IP address of the container
CONTAINER_IP=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID)

# Download the Jenkins CLI JAR file
sudo docker exec -u root jenkins wget "http://$CONTAINER_IP:8080/jnlpJars/jenkins-cli.jar"
#sudo docker exec -u root jenkins wget "http://172.17.0.2:8080/jnlpJars/jenkins-cli.jar"

#restart the system after installing the cli
sudo docker restart jenkins
#location to avoide the permission errror.I want edit config.xml file. inside container
#sudo docker exec -u root 9c6b6fd9e10c sed -i 's/old_string/new_string/g' /var/jenkins_home/config.xml

/var/jenkins_home/config.xml

#install gitlab using cli
sudo docker exec -u root jenkins java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:8080/ install-plugin gitlab-plugin

#sudo docker exec -u root jenkins java -jar /usr/share/jenkins/jenkins-cli.jar -s http://172.17.0.2:8080/ install-plugin gitlab-plugin
sudo docker exec -u root 9c6b6fd9e10c java -jar /jenkins-cli.jar -s http://172.17.0.2:8080/ install-plugin gitlab-plugin







