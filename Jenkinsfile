def elastic_ip
pipeline {
    agent any    
    stages {  
             stage('Lunch Ec2') {                  
                    steps {
                        sh 'sudo chmod +x launch_ec2_instance.sh'
                        sh './launch_ec2_instance.sh'                    
                    }
             }
         
            stage('Copy required Scripts') { 
                environment {
                   elastic_ip = sh(script: 'sudo cat $WORKSPACE/elastic_ip.txt', , returnStdout: true).trim()
               }
                steps {                        
                        sh 'echo ${elastic_ip}'                        
                        sh 'scp -o StrictHostKeyChecking=no $WORKSPACE/install_docker.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                        sh 'scp $WORKSPACE/install_docker_nginx.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                        sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker.sh'
                        sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker_nginx.sh'
                   
                }
            }
            stage('Installed Docker & Nginx') { 
                environment {
                   elastic_ip = sh(script: 'sudo cat $WORKSPACE/elastic_ip.txt', , returnStdout: true).trim()
               }
                steps {
                   
                        sh 'ssh ubuntu@${elastic_ip} ./install_docker.sh'
                        sh 'ssh ubuntu@${elastic_ip} ./install_docker_nginx.sh'
                    
                }
            }
            stage('Deploy Build') { 
                 environment {
                   elastic_ip = sh(script: 'sudo cat $WORKSPACE/elastic_ip.txt', , returnStdout: true).trim()
               }
                steps {
                    
                        sh 'scp $WORKSPACE/myapp/* ubuntu@${elastic_ip}:/home/ubuntu/myapp/'
                   
                }
            } 
           
                stage('Check Availability') {
                    environment {
                           elastic_ip = sh(script: 'sudo cat $WORKSPACE/elastic_ip.txt', , returnStdout: true).trim()
                       }
                  steps {                         
                          sh 'curl -s --head  --request GET  http://${elastic_ip} | grep "200"'                          
                              
                       
                    }
                }
          
        

    }
}
