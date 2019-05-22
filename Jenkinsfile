@Library('github.com/releaseworks/jenkinslib') _
pipeline {
    agent any
    stages {  
         stage('Launch instance') {                
                steps {                     
                      withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'aws-key', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                            AWS("aws ec2 run-instances --image-id $aws_image_id --count 1 --region us-east-1 --instance-type $i_type --key-name $aws_key_name --security-group-ids $sec_id --subnet-id $sub_id --associate-public-ip-address  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$tag - $uid},{Key=WatchTower,Value=$tag},{Key=AutomatedID,Value=$uid}]" | grep InstanceId ")
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
