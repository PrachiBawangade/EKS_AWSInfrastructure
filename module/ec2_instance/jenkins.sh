#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Update package list
echo "Updating package list..."
sudo apt-get update -y

# Install required dependencies
echo "Installing basic dependencies..."
sudo apt-get install -y ca-certificates curl unzip wget gnupg lsb-release fontconfig openjdk-17-jre git npm

echo "Basic dependencies installed."

# # Install Jenkins
# echo "Installing Jenkins..."
# sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
# echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update
# sudo apt-get install -y jenkins
# sudo systemctl enable --now jenkins
# echo "Jenkins installation complete."

# Install Docker
echo "Installing Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get remove --purge -y openjdk-11-jre
sudo apt-get install -y openjdk-17-jre
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo chmod 666 /var/run/docker.sock
# sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo systemctl enable --now docker
echo "Docker installation complete."

# Install Trivy
echo "Installing Trivy..."
sudo mkdir -p /usr/share/keyrings
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo tee /usr/share/keyrings/trivy.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.asc] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy
echo "Trivy installation complete."

# Install AWS CLI
# echo "Installing AWS CLI..."
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip -q awscliv2.zip
# sudo ./aws/install
# rm -rf awscliv2.zip aws
# echo "AWS CLI installation complete."

#Install AWS CLI(Skip if Already installed)
if ! command -v aws >/dev/null 2>&1; then
  echo "AWS CLI not found. Installing..."
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
else
  echo "AWS CLI is already installed. Skipping installation."
fi


# # Install Node.js using FNM
# echo "Installing Node.js..."
# curl -fsSL https://fnm.vercel.app/install | bash
# export PATH="$HOME/.fnm:$PATH"
# eval "$(fnm env)"
# fnm install 22
# fnm use 22
# node -v
# npm -v
# echo "Node.js installation complete."

#Install Node.js using nvm
# Check if Node.js is installed
    if ! command -v node >/dev/null 2>&1; then
     echo 'Node.js not found. Installing...'

    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash 
    export NVM_DIR=\"$HOME/.nvm\"
    [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"
    
    # Install Node.js (Latest LTS version)
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*

    echo 'Node.js installation completed.'
    else
    echo 'Node.js is already installed. Skipping installation.'
    fi

# # Install SonarQube
# echo "Installing SonarQube..."
# sudo apt-get install -y unzip

# # Create a dedicated user for SonarQube
# sudo adduser --system --no-create-home --group --disabled-login sonarqube
# sudo mkdir -p /opt/sonarqube

# # Download and extract SonarQube
# SONARQUBE_VERSION="9.4.0.54424"
# wget -qO sonarqube.zip "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"
# sudo unzip -q sonarqube.zip -d /opt/sonarqube
# sudo mv /opt/sonarqube/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube/latest
# rm -f sonarqube.zip

# # Set permissions
# sudo chown -R sonarqube:sonarqube /opt/sonarqube
# sudo chmod -R 755 /opt/sonarqube

# # Create SonarQube service
# cat <<EOF | sudo tee /etc/systemd/system/sonarqube.service
# [Unit]
# Description=SonarQube service
# After=network.target

# [Service]
# Type=simple
# User=sonarqube
# Group=sonarqube
# ExecStart=/opt/sonarqube/latest/bin/linux-x86-64/sonar.sh start
# ExecStop=/opt/sonarqube/latest/bin/linux-x86-64/sonar.sh stop
# Restart=always
# LimitNOFILE=65536

# [Install]
# WantedBy=multi-user.target
# EOF

# # Enable and start SonarQube
# sudo systemctl daemon-reload
# sudo systemctl enable --now sonarqube
# echo "SonarQube installation complete."

# # Display Jenkins initial password
# echo "Fetching Jenkins initial admin password..."
# sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# echo "All installations complete!"

# Install SonarQube
echo "Installing SonarQube..."
sudo apt-get install -y unzip

# Install Java 11 for SonarQube
echo "Installing OpenJDK 11 for SonarQube..."
sudo apt-get install -y openjdk-11-jre

# Create a dedicated user for SonarQube
if id "sonarqube" &>/dev/null; then
    echo "User sonarqube already exists, skipping creation."
else
    sudo useradd -r -m -d /opt/sonarqube -s /bin/bash sonarqube
fi

# Create a dedicated user for SonarQube
# if id "sonarqube" &>/dev/null; then
#     echo "User sonarqube already exists, skipping creation."
# else
#     sudo useradd -r -m -d /opt/sonarqube -s /bin/bash sonarqube
# fi

# Ensure SonarQube directory exists
sudo mkdir -p /opt/sonarqube

# Download and extract SonarQube
SONARQUBE_VERSION="2025.1.0.102418"
wget -qO sonarqube.zip "https://binaries.sonarsource.com/CommercialDistribution/sonarqube-developer/sonarqube-developer-${SONARQUBE_VERSION}.zip"
sudo unzip -q sonarqube.zip -d /opt/sonarqube
sudo mv /opt/sonarqube/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube/latest
rm -f sonarqube.zip

# Set permissions
sudo chown -R sonarqube:sonarqube /opt/sonarqube
sudo chmod -R 755 /opt/sonarqube


# Configure SonarQube settings
sudo tee /opt/sonarqube/latest/conf/sonar.properties > /dev/null <<EOL
sonar.telemetry.enable=true
sonar.jdbc.username=sonarqube
sonar.jdbc.password=sonarqube
sonar.web.javaAdditionalOpts=-server
sonar.search.javaAdditionalOpts=-Dnode.store.allow_mmap=false
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOL

# Create SonarQube service
cat <<EOF | sudo tee /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/latest/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/latest/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# Enable and start SonarQube
sudo systemctl daemon-reload
sudo systemctl enable --now sonarqube
echo "SonarQube installation complete."

# Display Jenkins initial password
# echo "Fetching Jenkins initial admin password..."
# sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "All installations complete!"