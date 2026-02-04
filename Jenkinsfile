pipeline {
    agent { label 'testing' } // This uses your agent-1 slave node
    stages {
        stage('Initialize') {
            steps {
                echo "Webhook received! Building branch: ${env.BRANCH_NAME}"
            }
        }
    }
}