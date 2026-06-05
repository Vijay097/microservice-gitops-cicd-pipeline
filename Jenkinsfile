pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "vijay021097/flask-microservice"
        IMAGE_TAG = "${env.BUILD_ID}"
    }
    
    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('1.5 Run Unit Tests') {
            steps {
                sh 'pip3 install -r requirements.txt'
                sh 'python3 -m pytest test_app.py -v'
            }   
        }
        
        stage('2. Build & Push Docker Image') {
            steps {
                script {
                    echo "Building Multi-Stage Image..."
                    sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest ."
                    
                    echo "Pushing to Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('3. Deploy to Private Kubernetes Cluster') {
            steps {
                echo "Deploying to Minikube via AWS SSM..."
                sh """
                aws ssm send-command \
                  --targets "Key=tag:Name,Values=WebServer-1,WebServer-2" \
                  --document-name "AWS-RunShellScript" \
                  --parameters 'commands=[
                    "export KUBECONFIG=/home/ec2-user/.kube/config",
                    "cd /home/ec2-user",
                    "if [ -d project-files ]; then cd project-files && git pull; else git clone https://github.com/Vijay097/microservice-gitops-cicd-pipeline.git project-files && cd project-files; fi",
                    "kubectl apply -f manifests-service.yaml",
                    "sed -i \\"s|IMAGE_PLACEHOLDER|vijay021097/flask-microservice:${BUILD_NUMBER}|\\" manifests-deployment.yaml",
                    "kubectl apply -f manifests-deployment.yaml",
                    "kubectl rollout status deployment/flask-microservice",
                    "pkill -f \\"kubectl port-forward\\" || true",
                    "nohup kubectl port-forward --address 0.0.0.0 svc/flask-service 30005:80 > /dev/null 2>&1 &"
                  ]'
                """
            }
        }
    }
}
