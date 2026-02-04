pipeline {
    agent { label 'testing' }
    
    environment {
        DB_PASS = credentials('DB_PASSWORD') 
        DB_USER = 'acctuser'
        SECRET_KEY = credentials('SECRET_KEY')
    }

    stages {

        stage('Build & Package') {
            steps {
                sh "echo '1.0.${env.BUILD_NUMBER}' > version.txt"
                
                sh "tar -czf login-app-v1.0.${env.BUILD_NUMBER}.tar.gz app.py requirements.txt version.txt init.sql"

                archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
                
                echo "Artifact login-app-v1.0.${env.BUILD_NUMBER}.tar.gz created and archived."
            }
        }

        stage('All branch testing') {
            steps {
                echo "Scanning ${env.BRANCH_NAME} for bad code..."
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
            when { expression { env.BRANCH_NAME != 'main' } }
            steps {
                echo "This is a feature branch: ${env.BRANCH_NAME}. Skipping deployment."
                echo "Running experimental unit tests..."
            }
        }
    }
}