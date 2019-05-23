
pipeline {
    agent any
    stages {  
         
            stage('Copy required Scripts') {                
                steps {
                      sshagent(['devops-ec2']) {
                        def elastic_ip=sh 'cat $WORKSPACE/elastic_ip.txt'
                          sh 'scp -o StrictHostKeyChecking=no $WORKSPACE/install_docker.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                        sh 'scp $WORKSPACE/install_docker_nginx.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                        sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker.sh'
                        sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker_nginx.sh'
                    }
                }
            }
            stage('Installed Docker & Nginx') {            
                steps {
                    sshagent(['devops-ec2']) {
                        sh 'ssh ubuntu@${elastic_ip} ./install_docker.sh'
                        sh 'ssh ubuntu@${elastic_ip} ./install_docker_nginx.sh'
                    }
                }
            }
            stage('Deploy Build') {            
                steps {
                    sshagent(['devops-ec2']) {
                        sh 'scp $WORKSPACE/myapp/* ubuntu@${elastic_ip}:/home/ubuntu/myapp/'
                   }
                }
            } 
           
                stage('Check Availability') {
                  steps {             
                      
                                    
                                  sh "curl -s --head  --request GET  http://${elastic_ip} | grep '200'"
                                  
                              
                       
                    }
                }
          
        

    }
}
