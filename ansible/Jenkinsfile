pipeline {
    agent any

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
        INVENTORY = "ansible/inventory/inventory.ini"
        PLAYBOOK = "ansible/playbooks/install_apache_php.yml"
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh '''
                cd $TF_DIR
                terraform init
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                cd $TF_DIR
                terraform apply -auto-approve
                '''
            }
        }

        stage('Verify Inventory') {
            steps {
                sh '''
                echo "Inventory file:"
                cat $INVENTORY
                '''
            }
        }

        stage('Run Ansible') {
            steps {
                sh '''
                ansible-playbook -i $INVENTORY $PLAYBOOK
                '''
            }
        }

        stage('Post Deployment Check') {
            steps {
                sh '''
                echo "Checking Apache status on servers..."
                ansible -i $INVENTORY all -m shell -a "systemctl status apache2 | grep active"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful!"
        }
        failure {
            echo "❌ Deployment Failed!"
        }
    }
}
