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
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        WORKSPACE_DIR = "${WORKSPACE}"
    }
    
    triggers {
        githubPush()
    }
    
    stages {
        stage('Validate Environment') {
            steps {
                script {
                    echo '✔️ Validating environment...'
                    sh '''
                        echo "Checking Python installation..."
                        python3 --version
                        
                        echo "Checking Ansible installation..."
                        ansible --version
                        
                        echo "Checking AWS CLI..."
                        aws --version || echo "AWS CLI not installed"
                    '''
                }
            }
        }
        
        stage('Checkout') {
            steps {
                script {
                    echo '🔄 Checking out code from GitHub...'
                    checkout scm
                    sh 'ls -la'
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
                    withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
                        dir('terraform') {
                            sh '''
                                echo "AWS Region: $AWS_DEFAULT_REGION"
                                terraform init
                                terraform plan -out=tfplan
                            '''
                        }
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
                    withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
                        dir('terraform') {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
        
        stage('Update Ansible Inventory') {
            steps {
                script {
                    echo '📝 Updating Ansible inventory from AWS...'
                    withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
                        sh '''
                            cd ansible
                            
                            # Create inventory directory
                            mkdir -p inventory
                            
                            # Get running EC2 instances
                            echo "Fetching running instances..."
                            aws ec2 describe-instances \
                                --filters "Name=instance-state-name,Values=running" \
                                --query "Reservations[*].Instances[*].PublicIpAddress" \
                                --output text > /tmp/ips.txt
                            
                            # Create inventory file
                            echo "[webservers]" > inventory/hosts
                            cat /tmp/ips.txt | tr ' ' '\\n' | grep -v '^$' >> inventory/hosts
                            
                            echo "" >> inventory/hosts
                            echo "[webservers:vars]" >> inventory/hosts
                            echo "ansible_user=ubuntu" >> inventory/hosts
                            echo "ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/aws-key.pem" >> inventory/hosts
                            echo "ansible_python_interpreter=/usr/bin/python3" >> inventory/hosts
                            
                            echo "✓ Updated inventory:"
                            cat inventory/hosts
                        '''
                    }
                }
            }
        }
        
        stage('Run Ansible Playbook') {
            steps {
                script {
                    echo '🚀 Running Ansible playbook...'
                    sshagent(['ansible-ssh-key']) {
                        sh '''
                            cd ansible
                            
                            # List hosts
                            echo "Hosts in inventory:"
                            cat inventory/hosts
                            
                            # Ping test
                            echo "Testing connectivity..."
                            ansible -i inventory/hosts webservers -m ping || true
                            
                            # Run playbook
                            echo "Running playbook..."
                            ansible-playbook -i inventory/hosts playbooks/site.yml -v
                        '''
                    }
                }
            }
        }
        
        stage('Verification') {
            steps {
                script {
                    echo '✔️ Verifying deployment...'
                    sshagent(['ansible-ssh-key']) {
                        sh '''
                            cd ansible
                            
                            echo "Checking Apache status..."
                            ansible -i inventory/hosts webservers -m systemd -a "name=apache2 state=started" || true
                            
                            echo "Checking PHP installation..."
                            ansible -i inventory/hosts webservers -m command -a "php -v" || true
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '📊 Pipeline execution completed'
        }
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed. Check logs above.'
        }
    }
}
