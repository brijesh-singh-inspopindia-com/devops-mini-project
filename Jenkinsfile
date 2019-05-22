pipeline {
    agent any
    stages {  
         stage('Launch instance') {                
                steps {                     
                      sh './launch_ec2_instance.sh'
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
