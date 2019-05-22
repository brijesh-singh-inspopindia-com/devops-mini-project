@Library('github.com/releaseworks/jenkinslib') _
pipeline {
    agent any
    stages {  
         stage('Launch instance') {                
                steps {                     
                      withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'aws-key', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                            AWS("aws ec2 run-instances --image-id ami-0a313d6098716f372 --count 1 --region us-east-1 --instance-type t2.micro --key-name devops-key --security-group-ids sg-0a0a7ff9c6298d97d --subnet-id subnet-095879cc20ee6471b --associate-public-ip-address  --tag-specifications | grep InstanceId")
                        }
                }
            }
            stage('Copy required Scripts') {                
                steps {
                      sshagent(['devops-ec2']) {
                        sh 'scp -o StrictHostKeyChecking=no $WORKSPACE/install_docker.sh ubuntu@3.212.118.113:/home/ubuntu/'
                        sh 'scp $WORKSPACE/install_docker_nginx.sh ubuntu@3.212.118.113:/home/ubuntu/'
                        sh 'ssh ubuntu@3.212.118.113 sudo chmod +x install_docker.sh'
                        sh 'ssh ubuntu@3.212.118.113 sudo chmod +x install_docker_nginx.sh'
                    }
                }
            }
            stage('Installed Docker & Nginx') {            
                steps {
                    sshagent(['devops-ec2']) {
                        sh 'ssh ubuntu@3.212.118.113 ./install_docker.sh'
                        sh 'ssh ubuntu@3.212.118.113 ./install_docker_nginx.sh'
                    }
                }
            }
            stage('Deploy Build') {            
                steps {
                    sshagent(['devops-ec2']) {
                        sh 'scp $WORKSPACE/myapp/* ubuntu@3.212.118.113:/home/ubuntu/myapp/'
                   }
                }
            } 
           
                stage('Check Availability') {
                  steps {             
                      
                                    
                                  sh "curl -s --head  --request GET  http://3.212.118.113 | grep '200'"
                                  
                              
                       
                    }
                }
          
        

    }
}
