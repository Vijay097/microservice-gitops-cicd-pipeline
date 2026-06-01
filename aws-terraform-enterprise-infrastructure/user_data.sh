#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
#sudo yum install nginx -y
#sudo systemctl start nginx
#sudo systemctl enable nginx
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
usermod -aG docker ec2-user
sleep 10


#!/bin/bash
# Redirect all output to a log file for debugging
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1

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