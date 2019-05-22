pipeline {
    agent any
    stages {        
            stage('Copy required Scripts') {                
                steps {
                      sshagent(['build-server']) {
                        sh 'scp -o StrictHostKeyChecking=no $WORKSPACE/install_docker.sh ubuntu@3.87.217.109:/home/ubuntu/'
                        sh 'scp $WORKSPACE/install_docker_nginx.sh ubuntu@3.87.217.109:/home/ubuntu/'
                        sh 'ssh ubuntu@3.87.217.109 sudo chmod +x install_docker.sh'
                        sh 'ssh ubuntu@3.87.217.109 sudo chmod +x install_docker_nginx.sh'
                    }
                }
            }
            stage('Installed Docker & Nginx') {            
                steps {
                    sshagent(['build-server']) {
                        sh 'ssh ubuntu@3.87.217.109 ./install_docker.sh'
                        sh 'ssh ubuntu@3.87.217.109 ./install_docker_nginx.sh'
                    }
                }
            }
            stage('Deploy Build') {            
                steps {
                    sshagent(['build-server']) {
                        sh 'scp $WORKSPACE/myapp/* ubuntu@3.87.217.109:/home/ubuntu/myapp/'
                   }
                }
            } 
           
                stage('Check Availability') {
                  steps {             
                      
                                    
                                  sh "curl -s --head  --request GET  http://3.87.217.109 | grep '200'"
                                  
                              
                       
                    }
                }
          
        

    }
}
