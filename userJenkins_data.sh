#!/bin/bash
# Redirect all outputs to a log file for real-time debugging and verification
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1

echo "================ STARTING PUBLIC SERVER BOOTSTRAP (AMAZON LINUX) ================"

# 1. Update the system packages
yum update -y

# 2. Install and configure Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add default Amazon Linux user (ec2-user) to the docker group
usermod -aG docker ec2-user

# 3. Install Java 17 (Required dependency for modern Jenkins engines)
yum install java-17-amazon-corretto-devel -y

# 4. Add the Official Jenkins Repository and Import GPG Encryption Key
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# 5. Install and start Jenkins
yum install -y jenkins
systemctl start jenkins
systemctl enable jenkins

# 6. CRITICAL DEVOPS INTEGRATION STEP
# This permits Jenkins to execute 'docker build' commands without throwing permission errors
usermod -aG docker jenkins
systemctl restart jenkins

echo "================ BOOTSTRAP COMPLETE ================"




