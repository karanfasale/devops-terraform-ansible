pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }
    
    parameters {
        booleanParam(name: 'RUN_TERRAFORM', defaultValue: false, description: 'Run Terraform to launch EC2?')
        string(name: 'INSTANCE_COUNT', defaultValue: '1', description: 'Number of EC2 instances')
    }
    
    environment {
        AWS_CREDENTIALS = credentials('aws-credentials')
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        WORKSPACE_DIR = "${WORKSPACE}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo '🔄 Checking out code from GitHub...'
                    checkout scm
                }
            }
        }
        
        stage('Terraform Init & Plan') {
            when {
                expression { params.RUN_TERRAFORM == true }
            }
            steps {
                script {
                    echo '🏗️ Initializing Terraform...'
                    dir('terraform') {
                        sh '''
                            terraform init
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.RUN_TERRAFORM == true }
            }
            steps {
                script {
                    echo '✅ Applying Terraform configuration...'
                    dir('terraform') {
                        sh 'terraform apply -auto-approve tfplan'
                        sh 'terraform output -json > ../ansible/inventory/aws_instances.json'
                    }
                }
            }
        }
        
        stage('Update Ansible Inventory') {
            steps {
                script {
                    echo '📝 Updating Ansible inventory from AWS...'
                    sh '''
                        cd ansible
                        # Use aws ec2 describe-instances to get IPs
                        aws ec2 describe-instances \
                            --filters "Name=instance-state-name,Values=running" \
                            --query "Reservations[*].Instances[*].[PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" \
                            --output text > inventory/hosts_temp
                        
                        # Format inventory file
                        echo "[webservers]" > inventory/hosts
                        awk '{print $1}' inventory/hosts_temp >> inventory/hosts
                        echo "" >> inventory/hosts
                        echo "[webservers:vars]" >> inventory/hosts
                        echo "ansible_user=ubuntu" >> inventory/hosts
                        echo "ansible_ssh_private_key_file=~/.ssh/aws-key.pem" >> inventory/hosts
                    '''
                }
            }
        }
        
        stage('Run Ansible Playbook') {
            steps {
                script {
                    echo '🚀 Running Ansible playbook...'
                    sh '''
                        cd ansible
                        # Install Ansible if not present
                        pip3 install ansible boto3 -q || true
                        
                        # Run playbook
                        ansible-playbook -i inventory/hosts playbooks/site.yml -v
                    '''
                }
            }
        }
        
        stage('Verification') {
            steps {
                script {
                    echo '✔️ Verifying deployment...'
                    sh '''
                        cd ansible
                        ansible -i inventory/hosts webservers -m command -a "curl -s http://localhost/ | head -5" || true
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo '📊 Pipeline execution completed'
            cleanWs()
        }
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed. Check logs above.'
        }
    }
}
