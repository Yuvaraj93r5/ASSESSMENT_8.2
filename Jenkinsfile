pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'your-dockerhub-username/student-feedback'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clones source control files locally into workspace
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')]) {
                        // Dynamically update image tags inside configuration manifest
                        sh "sed -i 's|your-dockerhub-username/student-feedback:v1|${DOCKER_IMAGE}:${IMAGE_TAG}|g' k8s-manifest.yaml"
                        sh "kubectl apply -f k8s-manifest.yaml --kubeconfig=\$KUBECONFIG"
                    }
                }
            }
        }

        stage('Verify Deployment Status') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')]) {
                        sh "kubectl rollout status deployment/student-feedback-deployment --kubeconfig=\$KUBECONFIG"
                        sh "kubectl get pods -l app=student-feedback --kubeconfig=\$KUBECONFIG"
                    }
                }
            }
        }
    }
}
