#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1
echo "================ STARTING KUBERNETES BOOTSTRAP ================"

# Update system and install dependencies
yum update -y
yum install -y docker git
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# Start minikube as ec2-user
su - ec2-user -c "minikube start --driver=docker"

# Setup kubeconfig properly
su - ec2-user -c "mkdir -p ~/.kube"
su - ec2-user -c "minikube kubectl -- config view --flatten > ~/.kube/config"

# Clone repository to get Kubernetes manifests
#su - ec2-user -c "cd ~ && git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git"

# Copy manifests to home directory for easy access
#su - ec2-user -c "cp ~/YOUR_REPO_NAME/manifests-*.yaml ~/"

# Apply the service manifest (create NodePort service)
#su - ec2-user -c "kubectl apply -f ~/manifests-service.yaml"

echo "================ BOOTSTRAP COMPLETE ================"