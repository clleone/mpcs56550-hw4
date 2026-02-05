pipeline {
    agent { label 'testing' }
    
    environment {
        DB_PASSWORD = credentials('DB_PASSWORD') 
        DB_USER = 'acctuser'
        SECRET_KEY = credentials('SECRET_KEY')
        ROOT_PASS = credentials('MYSQL_ROOT_PASS')
        SONAR_TOKEN = credentials('SONAR_TOKEN')
    }
    // to push
    stages {
        stage('Install Dependencies') {
            steps {
                sh "docker build --no-cache -t login-app-build ."
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

        stage('All branch quality analysis with SonarQube') {
            steps {
                echo "Scanning ${env.BRANCH_NAME} for bad code with SonarQube..."
                 script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner " +
                        "-Dsonar.projectKey=flask-login-app " +
                        "-Dsonar.sources=. " +
                        "-Dsonar.python.version=3 " +
                        "-Dsonar.token=${env.SONAR_TOKEN}"
                    }
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Staging Deployment') {
            // main only
            when { branch 'master' }
            steps {
                echo "Branch is master. Deploying to Staging Database..."
                script {
                    // restart containers
                    sh 'docker stop flask-app || true'
                    sh 'docker rm flask-app || true'
            
                    echo "Building Staging Database from scratch..."
                    sh "docker exec -i mysql-db mysql -uroot -p${ROOT_PASS} < init.sql"

                    echo "Verifying Successful Seeding..."
                    sh "docker exec -i mysql-db mysql -uroot -p${ROOT_PASS} login_db -e 'SELECT * FROM accounts;'"

                    // Debug: Check environment variables
                    sh "echo 'DB_USER is: ${DB_USER}'"
                    sh "echo 'DB_PASS length:' && echo '${DB_PASSWORD}' | wc -c"
                    
                    echo "Booting up application..."
                    sh """
                    docker run -d --name flask-app \
                    --network 4w_jenkins-net \
                    -p 5000:5000 \
                    -e DB_HOST=mysql-db \
                    -e DB_USER=${DB_USER} \
                    -e DB_PASSWORD='${DB_PASSWORD}' \
                    -e DB_NAME=login_db \
                    -e SECRET_KEY='${SECRET_KEY}' \
                    login-app-build
                    """
                    
                    echo "Waiting for Flask app to start..."
                    sh "sleep 5"
                    
                    // Debug: Check what environment variables the container received
                    sh "docker exec flask-app env | grep DB_"
                }
            }
        }
        // comment to push
        stage('End-to-End Testing') {
            when { branch 'master' }
            steps {
                sh """
                docker run --rm \
                --network 4w_jenkins-net \
                --volumes-from jenkins-agent-1 \
                -w ${WORKSPACE} \
                -e APP_URL=http://flask-app:5000 \
                mcr.microsoft.com/playwright/python:v1.40.0-jammy \
                bash -c 'ls -lat && pip install -r requirements.txt && playwright install chromium && pytest --html=report.html'
                """
                archiveArtifacts artifacts: 'report.html', fingerprint: true
            }
        }

        stage('Performance Testing') {
            when { branch 'master' }
            steps {
                sh """
                docker run --rm \
                --network 4w_jenkins-net \
                --volumes-from jenkins-agent-1 \
                -w ${WORKSPACE} \
                grafana/k6 run performance.js
                """
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
    post {
        success {
            // 'slack-token' is the ID of your Secret Text credential containing the URL
            slackSend(color: 'good', tokenCredentialId: 'slack-token', channel: '#devops', message: "✅ Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
        failure {
            slackSend(color: 'danger', tokenCredentialId: 'slack-token', channel: '#devops', message: "🚨 Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env.BUILD_URL}console")
        }
    }
}