pipeline {
    agent { label 'testing' }
    
    environment {
        DB_PASS = credentials('DB_PASSWORD') 
        DB_USER = 'acctuser'
        SECRET_KEY = credentials('SECRET_KEY')
        ROOT_PASS = credentials('MYSQL_ROOT_PASS')
    }

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
                           "-Dsonar.python.version=3"
                    }
                }
            }
        }
        // comment to push
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
                    echo "Building Staging Database from scratch..."
                    sh "docker exec -i mysql-db mysql -uroot -p${ROOT_PASS} < init.sql"

                    echo "Verifying Successful Seeding..."
                    sh "docker exec -i mysql-db mysql -uroot -p${ROOT_PASS} login_db -e 'SELECT * FROM accounts;'"

                    echo "Booting up application..."
                    sh "docker run -d --name flask-app --network 4w_jenkins-net -p 5000:5000 login-app-build"
                }
            }
        }
        // comment to push
        stage('End-to-End Testing') {
            when { branch 'master' }
            steps {
                // restart containers -- push
                sh 'docker stop flask-app || true'
                sh 'docker rm flask-app || true'
                sh """
                echo "=== Checking workspace contents ==="
                ls -la
                
                echo "=== Running docker with debug ==="
                docker run --rm \
                --network 4w_jenkins-net \
                -v \$(pwd):/app \
                -w /app \
                -e APP_URL=http://flask-app:5000 \
                mcr.microsoft.com/playwright/python:v1.40.0-jammy \
                bash -c 'pwd && ls -la && pip install -r requirements.txt && playwright install chromium && pytest --html=report.html'
                """
                archiveArtifacts artifacts: 'report.html', fingerprint: true
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