
pipeline {
    agent any
    stages {  
         
            stage('Copy required Scripts') {                
                steps {
                        sh 'sudo chmod 777 /var/lib/jenkins/workspace/launch-job/elastic_ip.txt'
                        elastic_ip=sh 'sudo cat /var/lib/jenkins/workspace/launch-job/elastic_ip.txt'
                        GIT_COMMIT_EMAIL = sh (
                            script: 'sudo cat /var/lib/jenkins/workspace/launch-job/elastic_ip.txt',
                            returnStdout: true
                        ).trim()
                        echo "Git committer email: ${GIT_COMMIT_EMAIL}"
                    
                        sh 'echo helloworld1'
                        sh 'echo ${elastic_ip}'
                        sh 'echo helloworld2'
                        sh 'scp -o StrictHostKeyChecking=no $WORKSPACE/install_docker.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                        sh 'scp $WORKSPACE/install_docker_nginx.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                        sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker.sh'
                        sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker_nginx.sh'
                   
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
