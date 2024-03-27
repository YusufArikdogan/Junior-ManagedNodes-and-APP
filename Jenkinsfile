pipeline {
    agent any
    tools {
        terraform 'terraform'
    }

    stages {
        
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
       stage('Terraform Plan & Apply') {
            steps {
                script {
                    echo 'Initializing Terraform...'
                    def initResult = sh(script: 'terraform init -reconfigure', returnStatus: true)
                    if (initResult != 0) {
                        error 'Terraform initialization failed. Please check and try again.'
                    }
                    
                    def buildNumber = env.BUILD_NUMBER
                    echo "Using Jenkins build number: ${buildNumber}"
                    
                    echo 'Applying Terraform changes...'
                    sh "terraform apply --auto-approve -var 'build_number=${buildNumber}'"
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
                sh 'docker build --force-rm -t "insaniso/postgre:latest" -f ./postgresql/Dockerfile .'
                sh 'docker build --force-rm -t "insaniso/nodejs:latest" -f ./nodejs/Dockerfile .'
                sh 'docker build --force-rm -t "insaniso/react:latest" -f ./react/Dockerfile .'
                sh 'docker image ls'
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo 'Pushing App Image to Docker Hub'
                withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD'
                    sh 'docker push insaniso/postgre:latest'
                    sh 'docker push insaniso/nodejs:latest'
                    sh 'docker push insaniso/react:latest'
                }
            }
        }

        stage('Wait for the Instance') {
            steps {
                script {
                    echo 'Waiting for the instance'
                    id = sh(script: 'aws ec2 describe-instances --filters Name=tag-value,Values=ansible_postgresql Name=instance-state-name,Values=running --query Reservations[*].Instances[*].[InstanceId] --output text',  returnStdout: true).trim()
                    sh 'aws ec2 wait instance-status-ok --instance-ids $id'
                }
            }
        }

        stage('Deploy the App') {
            steps {
                echo 'Deploy the App'
                sh 'ls -l'
                sh 'ansible --version'
                sh 'ansible-inventory --graph'
                ansiblePlaybook credentialsId: 'ansible', disableHostKeyChecking: true, installation: 'ansible', inventory: 'inventory_aws_ec2.yml', playbook: 'Junior-Level.yaml'
            }
        }

        stage('Destroy the Infrastructure') {
            steps {
                timeout(time: 5, unit: 'DAYS') {
                    input message: 'Approve terminate'
                }
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
            sh 'terraform destroy --auto-approve'
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
