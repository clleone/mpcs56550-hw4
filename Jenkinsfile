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
                sh "docker build -t my-login-app ."
                sh "docker run --rm my-login-app pip install -r requirements.txt"
            }
        }

        stage('All branch testing') {
            steps {
                echo "Scanning ${env.BRANCH_NAME} for bad code..."
            }
        }

        stage('Staging Deployment') {
            // main only
            when { branch 'main' }
            steps {
                echo "Branch is main. Deploying to Staging Database..."
                sh 'docker exec mysql-db mysql -uapp_user -psecretpassword login_db < init.sql'
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