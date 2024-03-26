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
                    sh 'terraform init'
                    
                    def buildNumber = env.BUILD_NUMBER
                    echo "Using Jenkins build number: ${buildNumber}"
                    
                    echo 'Applying Terraform changes...'
                    sh "terraform apply --auto-approve -var 'build_number=${buildNumber}'"
                }
            }
        }

        stage('Build App Docker Image') {
            steps {
                echo 'Building App Docker Image...'
                // Docker image build steps
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                echo 'Pushing App Image to Docker Hub...'
                // Docker image push steps
            }
        }

        stage('Deploy the App') {
            steps {
                echo 'Deploying the App...'
                // App deployment steps
            }
        }

        // stage('Destroy Old Infrastructure') {
        //     steps {
        //         echo 'Destroying the Old Infrastructure...'
        //         sh """
        //         terraform destroy --auto-approve
        //         """
        //     }
        // }
    }

    post {
        always {
            echo 'Deleting all local images...'
            sh 'docker image prune -af'
            sh 'terraform destroy --auto-approve'
        }
        failure {
            echo 'Clean-up due to failure...'
            sh """
                docker image prune -af
                terraform destroy --auto-approve
                """
        }
    }
}
