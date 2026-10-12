pipeline {
    agent any

    environment {
        IMAGE_NAME = "raja3333/sample-app"
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage("Validate") {
            steps {
                sh 'test -f Dockerfile'
                sh 'docker version'
            }
        }

        stage("Build Image") {
            steps {
                sh 'docker build --pull -t "$IMAGE_NAME:$BUILD_NUMBER" -t "$IMAGE_NAME:latest" .'
            }
        }

        stage("Scan Image") {
            steps {
                sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME/.cache/trivy:/root/.cache/" aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE_NAME:$BUILD_NUMBER"'
            }
        }

        stage("Push to Docker Hub") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "dockerhub-creds",
                    usernameVariable: "DOCKERHUB_USER",
                    passwordVariable: "DOCKERHUB_TOKEN"
                )]) {
                    sh '''
                        set +x
                        echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push "$IMAGE_NAME:$BUILD_NUMBER"
                        docker push "$IMAGE_NAME:latest"
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f'
        }
        success {
            echo 'Image built, scanned, and pushed successfully.'
        }
        failure {
            echo 'Pipeline failed; inspect logs and do not bypass a failed security scan without approval.'
        }
    }
}
