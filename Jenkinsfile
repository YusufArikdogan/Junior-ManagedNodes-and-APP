pipeline {
    agent any
    tools {
        terraform 'terraform'
    }

    environment {
        PATH=sh(script:"echo $PATH:/usr/local/bin", returnStdout:true).trim()
        AWS_REGION = "us-east-1"
        DOCKERHUB_USERNAME = "insaniso"
        DOCKERHUB_PASSWORD = "dckr_pat_XgUyvGfEEwW9CWcNEP5lQazKlI8"
        // DOCKERHUB_USERNAME = credentials('dockerhub_username')
        // DOCKERHUB_PASSWORD = credentials('dockerhub_password')
        DOCKERHUB_REGISTRY = "insaniso"
        POSTGRE_REPO_NAME = "postgre"
        NODEJS_REPO_NAME = "nodejs"
        REACT_REPO_NAME = "react"
        APP_NAME = "todo"
    }

    stages {
        stage('Create Infrastructure for the App') {
            steps {
                echo 'Creating Infrastructure'
                script {
                    // Check if infrastructure already exists
                    def infraExists = sh(script: 'terraform state list', returnStatus: true) == 0
                    if (!infraExists) {
                        sh 'terraform init'
                        sh 'terraform apply --auto-approve'
                    } else {
                        echo 'Infrastructure already exists. Skipping...'
                    }
                }
            }
        }

        stage('Build App Docker Image') {
            steps {
                echo 'Building App Image'
                script {
                    env.NODE_IP = sh(script: 'terraform output -raw node_public_ip', returnStdout:true).trim()
                    env.DB_HOST = sh(script: 'terraform output -raw postgre_private_ip', returnStdout:true).trim()
                }
                sh 'echo ${DB_HOST}'
                sh 'echo ${NODE_IP}'
                sh 'envsubst < node-env-template > ./nodejs/server/.env'
                sh 'cat ./nodejs/server/.env'
                sh 'envsubst < react-env-template > ./react/client/.env'
                sh 'cat ./react/client/.env'
                sh 'docker build --force-rm -t "$DOCKERHUB_REGISTRY/$POSTGRE_REPO_NAME:latest" -f ./postgresql/Dockerfile .'
                sh 'docker build --force-rm -t "$DOCKERHUB_REGISTRY/$NODEJS_REPO_NAME:latest" -f ./nodejs/Dockerfile .'
                sh 'docker build --force-rm -t "$DOCKERHUB_REGISTRY/$REACT_REPO_NAME:latest" -f ./react/Dockerfile .'
                sh 'docker image ls'
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo 'Pushing App Image to Docker Hub'
                sh 'docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD'
                sh 'docker push $DOCKERHUB_REGISTRY/$POSTGRE_REPO_NAME:latest'
                sh 'docker push $DOCKERHUB_REGISTRY/$NODEJS_REPO_NAME:latest'
                sh 'docker push $DOCKERHUB_REGISTRY/$REACT_REPO_NAME:latest'
            }
        }

        stage('Wait for the instance') {
            steps {
                echo 'Waiting for the instance'
                id = sh(script: 'aws ec2 describe-instances --filters Name=tag-value,Values=ansible_postgresql Name=instance-state-name,Values=running --query Reservations[*].Instances[*].[InstanceId] --output text',  returnStdout:true).trim()
                sh 'aws ec2 wait instance-status-ok --instance-ids $id'
            }
        }

        stage('Deploy the App') {
            steps {
                echo 'Deploy the App'
                sh 'ls -l'
                sh 'ansible --version'
                sh 'ansible-inventory --graph'
                ansiblePlaybook credentialsId: 'yusufkey', disableHostKeyChecking: true, installation: 'ansible', inventory: 'inventory_aws_ec2.yml', playbook: 'Junior-Level.yaml'
            }
        }

        stage('Destroy the infrastructure') {
            steps {
                timeout(time:5, unit:'DAYS'){
                    input message:'Approve terminate'
                }
                echo 'Destroying the infrastructure'
                sh """
                docker image prune -af
                terraform destroy --auto-approve
                """
            }
        }

    }

    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
        failure {
            echo 'Clean-up due to failure'
            sh """
                docker image prune -af
                terraform destroy --auto-approve
                """
        }
    }
}
