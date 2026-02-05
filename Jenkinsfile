pipeline {
    agent { label 'testing' }
    
    environment {
        DB_PASS = credentials('DB_PASSWORD') 
        DB_USER = 'acctuser'
        SECRET_KEY = credentials('SECRET_KEY')
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh "docker build -t login-app-build ."
                sh "docker run --rm login-app-build pip install -r requirements.txt"
            }
        }

        stage('Build & Package') {
            steps {
                sh "echo '1.0.${env.BUILD_NUMBER}' > version.txt"
                
                sh "tar -czf login-app-v1.0.${env.BUILD_NUMBER}.tar.gz app.py requirements.txt version.txt init.sql"

                archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
                
                echo "Artifact login-app-v1.0.${env.BUILD_NUMBER}.tar.gz created and archived."
            }
        }
        //random comment so I can push
        stage('All branch quality analysis with SonarQube') {
            steps {
                echo "Scanning ${env.BRANCH_NAME} for bad code with SonarQube..."
                 script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner " +
                           "-Dsonar.projectKey=flask-login-app " +
                           "-Dsonar.sources=. " +
                           "-Dsonar.python.version=3"
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Staging Deployment') {
            // main only
            when { branch 'master' }
            steps {
                echo "Branch is master. Deploying to Staging Database..."
                // sh 'docker exec mysql-db mysql -uapp_user -psecretpassword login_db < init.sql'
            }
        }

        stage('Feature Lab') {
            // feature only
            when { expression { env.BRANCH_NAME != 'master' } }
            steps {
                echo "This is a feature branch: ${env.BRANCH_NAME}. Skipping deployment."
                echo "Running experimental unit tests..."
            }
        }
    }
}