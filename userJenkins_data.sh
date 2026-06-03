#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1
echo "================ STARTING JENKINS BOOTSTRAP ================"

yum update -y
yum install -y docker python3-pip git
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

yum install java-21-amazon-corretto-devel -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
yum install -y jenkins

# 🔥 NEW: Tell Jenkins to skip the setup wizard completely
mkdir -p /var/lib/jenkins/init.groovy.d/
echo 'import jenkins.model.*
import hudson.util.*
import jenkins.install.*
// Disable the setup wizard
Jenkins.instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)' > /var/lib/jenkins/init.groovy.d/basic-security.groovy
systemctl daemon-reload
# Start Jenkins with the wizard disabled
systemctl start jenkins
systemctl enable jenkins

usermod -aG docker jenkins
systemctl restart jenkins

echo "================ BOOTSTRAP COMPLETE ================"