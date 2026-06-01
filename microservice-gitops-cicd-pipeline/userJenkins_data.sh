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
echo "================ STARTING BOOTSTRAP (AMAZON LINUX) ================"


curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 4. Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# 5. Start Minikube SAFELY as the 'ec2-user'
# This ensures config files are generated in /home/ec2-user/.kube/
su - ec2-user -c "minikube start --driver=docker"

echo "================ BOOTSTRAP COMPLETE ================"