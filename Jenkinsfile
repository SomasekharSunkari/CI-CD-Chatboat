pipeline{
    agent any
    tools{
        jdk 'jdk-17'
        nodejs 'nodejs'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('Checkout from Git'){
            steps{
                git branch: 'legacy', url: 'https://github.com/SomasekharSunkari/chatbot-ui.git'            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Chatbot \
                    -Dsonar.projectKey=Chatbot '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'dp-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.json"
            }
        }
        stage("Docker Build and  Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'dockerhub-cred', toolName: 'docker'){
                       sh "docker build -t chatbot ."
                       sh "docker tag chatbot sunkarisomasekhar/chatbot:latest "
                       sh "docker push sunkarisomasekhar/chatbot:latest "
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image sunkarisomasekhar/chatbot:latest > trivy.json"
            }
        }
        stage ("Remove container") {
            steps{
                sh "docker stop chatbot || true"
                sh "docker rm chatbot || true"
             }
        }
        stage('Deploy to container'){
            steps{
                sh 'docker run -d --name chatbot -p 3000:3000 sunkarisomasekhar/chatbot:latest'
            }
        }
        stage('Deploy to kubernets'){
            steps{
                script{
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s-creds', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                          sh 'kubectl apply -f k8s/chatbot-ui.yaml'
                    }
                   
                }
            }
        }
        // stage('Trivy k8s Cluster Scan'){
        //     steps{
        //         script{
        //             withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s-creds', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
        //                   sh 'trivy k8s --report summary cluster'
        //             }
                   
        //         }
        //     }
        // }
        
    }
    }
