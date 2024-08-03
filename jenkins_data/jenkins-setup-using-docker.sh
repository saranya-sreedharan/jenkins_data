#!/bin/bash

# Colors for text formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display error message and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Function to display success message
success_msg() {
    echo -e "${GREEN}$1${NC}"
}

# Update package repositories
echo "Updating package repositories..."
sudo apt update || error_exit "Failed to update package repositories."
#create a directory in local
mkdir jenkins_data
# Install Docker
echo "Installing Docker..."
sudo apt install docker.io -y || error_exit "Failed to install Docker."

# Create Docker volumes
echo "Creating Docker volumes..."
sudo docker volume create jenkins_data || error_exit "Failed to create Docker volume jenkins_data."
sudo docker volume create --driver local --opt type=none --opt device=/mnt/jenkins_data --opt o=bind jenkins_data || error_exit "Failed to create Docker volume jenkins_data."

# Change ownership and permissions of Jenkins data directory
echo "Changing ownership and permissions of Jenkins data directory..."
sudo chown -R 1000:1000 /home/ubuntu/jenkins_data || error_exit "Failed to change ownership of Jenkins data directory."
sudo chmod -R 777 /home/ubuntu/jenkins_data || error_exit "Failed to change permissions of Jenkins data directory."

# Run Jenkins container
echo "Running Jenkins container..."
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_data:/var/jenkins_home --name jenkins --restart always jenkins/jenkins:lts || error_exit "Failed to run Jenkins container."



# Get the container ID of the container named "jenkins"
CONTAINER_ID=$(sudo docker ps -aqf "name=jenkins")

# Check if the container ID is not empty
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
/var/jenkins_home/config.xml

#install gitlab using cli
#sudo docker exec -u root jenkins java -jar /jenkins-cli.jar -s http://$CONTAINER_ID:8080/ install-plugin gitlab-plugin

#sudo docker exec -u root jenkins java -jar /usr/share/jenkins/jenkins-cli.jar -s http://172.17.0.2:8080/ install-plugin gitlab-plugin




