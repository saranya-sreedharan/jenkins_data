#!/bin/bash

# Colors for text formatting
RED='\033[0;31m'
NC='\033[0m'      # No Color
YELLOW='\033[33m'
GREEN='\033[32m'

# Function to display error message and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Function to display success message
success_msg() {
    echo -e "${GREEN}$1${NC}"
}

# Taking the input from user
echo "${YELLOW}...Enter the Git repository URL:...${NC}"
read GIT_REPO_NAME

echo "${YELLOW}...Enter the Git branch name:....${NC}"
read GIT_BRANCH_NAME

echo "${YELLOW}....Enter the target remote host:....${NC}"
read TARGET_REMOTE_HOST

echo "${YELLOW}...Enter the target user:...${NC}"
read TARGET_REMOTE_USER

echo "${YELLOW}....Enter the target folder location:....${NC}"
read TARGET_FOLDER_LOCATION

echo "${GREEN}...Input taking from user is completed....${NC}"

# Check if any input is empty
if [[ -z $GIT_REPO_NAME || -z $GIT_BRANCH_NAME || -z $TARGET_REMOTE_HOST || -z $TARGET_REMOTE_USER || -z $TARGET_FOLDER_LOCATION ]]; then
    error_exit "One or more input fields are empty. Please provide all the required inputs."
else
    success_msg "All input fields are provided."
fi

# Install Docker
echo "${YELLOW}... Installing Docker....${NC}"
sudo apt update
sudo apt install docker.io -y || error_exit "Failed to install Docker."
success_msg "Docker installed successfully."

# Create Dockerfile
echo "${YELLOW}... Creating Dockerfile....${NC}"
cat <<EOF | sudo tee Dockerfile > /dev/null
FROM jenkins/jenkins:lts
EXPOSE 8080 50000
VOLUME /var/jenkins_home
CMD ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
EOF
success_msg "Dockerfile created successfully."

# Build Jenkins image
echo "${YELLOW}... Building Jenkins image....${NC}"
sudo docker build -t my-custom-jenkins . || error_exit "Failed to build Jenkins image."
success_msg "Jenkins image built successfully."

# Run Jenkins container
echo "${YELLOW}... Running Jenkins container....${NC}"
sudo docker run -d -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_data:/var/jenkins_home --name jenkins --restart always jenkins/jenkins:lts || error_exit "Failed to run Jenkins container."
sudo chown -R 1000:1000 /home/ubuntu/jenkins_data
sudo chmod -R 777 /home/ubuntu/jenkins_data
#wait_for_container "jenkins" || error_exit "Failed to start Jenkins container."
success_msg "Jenkins container is up and running."

sleep 30

# Restart Jenkins container to apply plugin changes
echo "${YELLOW}... Restarting Jenkins container to apply plugin changes....${NC}"
sudo docker restart jenkins || error_exit "Failed to restart Jenkins container."
success_msg "Jenkins container restarted successfully."

# Wait for Jenkins container to restart
echo "${YELLOW}... Waiting for Jenkins container to restart....${NC}"
sleep 30

# Create admin user with full privileges
echo "${YELLOW}... Creating admin user with full privileges....${NC}"
sudo docker exec jenkins java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ create-user <admin-username> <admin-password> || error_exit "Failed to create admin user."
success_msg "Admin user created successfully."

# Display Jenkins initial admin password
echo "${YELLOW}... Displaying Jenkins initial admin password....${NC}"
initial_admin_password=$(sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
echo "Initial Admin Password: $initial_admin_password"
success_msg "Jenkins initial admin password displayed successfully."



curl -X POST \
  -H "Authorization: sso-key A535dqnbBHF_DnvzSwqRvYCkW5HdBwVaS7:3yFX8ZB5D71dT5J9D3Fpz5" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '[
        {
          "data": "44.220.132.113",
          "ttl": 3600
        }
      ]' \
  "https://api.godaddy.com/v1/domains/mnserviceproviders.com/records/A/saru"


curl -X GET \
  -H "Authorization: sso-key :YOUR_API_SECRET" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  "https://api.godaddy.com/v1/domains/YOUR_DOMAIN/records"
