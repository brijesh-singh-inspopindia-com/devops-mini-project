## devops-mini-project

# Porject plan:
- we will create a ec2 ubuntu machine from aws console to install jenkins on that machine
- for this setup, we can create a custom VPC with public subnet,internet gateway attached to VPC,route table update for VPC and subnet for internet gateway
- we require an elastic ip to associate with ec2 instance on which we will access jenkins on port 8080
- we need to create a keypair and security group accessible for port 22,8080,80,443 (ssh,custom tcp,http,https)
- we will note down all id's of above resources e.g. vpc-id,security group-id,route table id ,subnet id etc. 
- these above things will be used for launching a ec2 machine through aws cli using shell script and integrate this to jenkins pipeling (we will use declarative pipeline for this setup on jenkins)
- when new ec2 machine will be launch through jenkins pipeline in first stage , we will do a docker installation for creating a nginx container on which we will deploy our app (a single index.html file as given in requirement)
- we will create separate shell script file for installation of above things
- all these shell scripts will be available on github repository

#Initial Setup:

- create a git repository for this project named "devops-mini-project"
- add few files within this repo
  * install_java_jenkins.sh
  ```sh
  #!/bin/bash
    sudo apt-get update -y
    sudo apt-get upgade -y
    sudo apt-get install openjdk-8-jdk -y
    java -version
    sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update -y
    sudo apt-get install jenkins -y
    sudo systemctl start jenkins
    sudo ufw allow 8080
  ```
  * install_aws_cli.sh
  ```sh
  #!/bin/bash
    sudo apt-get install python2.7 -y
    curl -O https://bootstrap.pypa.io/get-pip.py
    sudo python2.7 get-pip.py 
    sudo pip install awscli
  ```
    * we will do aws configuration setting on above machine later when jenkins and aws cli will be installed

- create an aws free tier account, if you have already then use that one
- go to aws console and create below given resources
- custom vpc,public subnet,internet gateway,route table,elastic ip,security group,keypair
- now we will go to launch an ec2 ubuntu machine from aws console and select our above resources to lunch new instance in our defined scope of VPC
- when ec2 instance will be ready , we will attach an elastic ip to this instance
- now time to go on server using putty and private key file 
- on ec2 machine terminal window , we will write few lines and execute it
```sh
$ git clone https://github.com/brijesh-singh-inspopindia-com/devops-mini-project.git
cd devops-mini-project
sudo chmod +x install_java_jenkins.sh
./install_java_jenkins.sh
```
- when jenkins will be installed , we need to install aws cli and its configuration
```sh
sudo chmod +x install_aws_cli.sh
./install_aws_cli.sh
```
- after that we required to configure aws cli with access key and secrete key
  * aws_access_key_id  & aws_secret_access_key  will be as per our security credential, i am not putting it here
    ```sh
    aws configure set aws_access_key_id ***** 
    aws configure set aws_secret_access_key *****
    aws configure set region us-east-1 
    aws configure set output json
    aws --version
    ```
- now our jenkins mahcine is ready to launch
- go to browser and access the jenkin with server host ip with port 8080
- it will ask for password and show password path, we can take this from jenkins machine with terminal
- put the password and click on submit/next to install few prerequisite jenkins plugin
- after that we will create a jenkins user with username and password and click next - it will show jenkins launch url with complete address which will be used further to create jobs inside jenkins
- its time to create a shell script using aws cli commands to lanuch a new ec2 ubuntu machine with all details captured during project initial setup
- shell script file named "launch_ec2_instance.sh" created with all details, file content is too long so i am not putting here, you can check on github repo
- on this new machine we need to setup docker and nginx for our webserver
 * create a shell script file for installing docker 
 ```sh
     #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt-get update -y
    apt-cache policy docker-ce -y
    sudo apt-get install docker-ce -y
    sudo systemctl status docker
 ```
 * create a shell script file for docker container of nginx server
 ```sh
     #!/bin/bash
    cd  /home/ubuntu/
    sudo mkdir myapp
    cd myapp
    sudo touch index.html
    sudo chmod 777 index.html
    sudo echo "Hi, this is nginx server volumn folder index file" > index.html
    sudo docker pull nginx
    sudo docker rm -f mynginx
    sudo docker run -itd --name=mynginx -v /home/ubuntu/myapp:/usr/share/nginx/html:ro -p 80:80  nginx
 ```
 - we also require a actual index.html file having contect "Automation for people" on github which will be deployed later on nginx server
 - create a folder myapp and an index.html file inside that one with content "Automation for people"
- Now we will create a jenkins pipeline file in github project named "Jenkinsfile"
```
    def elastic_ip
    pipeline {
        agent any
        environment {
           elastic_ip = sh(script: 'sudo cat $WORKSPACE/elastic_ip.txt', , returnStdout: true).trim()
       }
        stages {  
                 stage('Lunch Ec2') {                  
                        steps {
                            sh 'sudo chmod +x launch_ec2_instance.sh'
                            sh './launch_ec2_instance.sh'                    
                        }
                 }
             
                stage('Copy required Scripts') {                  
                    steps {                        
                            sh 'echo ${elastic_ip}'                        
                            sh 'scp -o StrictHostKeyChecking=no $WORKSPACE/install_docker.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                            sh 'scp $WORKSPACE/install_docker_nginx.sh ubuntu@${elastic_ip}:/home/ubuntu/'
                            sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker.sh'
                            sh 'ssh ubuntu@${elastic_ip} sudo chmod +x install_docker_nginx.sh'
                    }
                }
                stage('Installed Docker & Nginx') {            
                    steps {
                            sh 'ssh ubuntu@${elastic_ip} ./install_docker.sh'
                            sh 'ssh ubuntu@${elastic_ip} ./install_docker_nginx.sh'
                    }
                }
                stage('Deploy Build') {            
                    steps {
                            sh 'scp $WORKSPACE/myapp/* ubuntu@${elastic_ip}:/home/ubuntu/myapp/'
                    }
                } 
                    stage('Check Availability') {
                      steps {                         
                              sh 'curl -s --head  --request GET  http://${elastic_ip} | grep "200"'  
                        }
                    }
        }
    }
```
- Its final time to create a jenkins job for creating an ec2 instance with a webserver on which we will deploy our index.html file
- create a new job named "devops-demo-job" as pipeling project
- set buid Pipeline as pipeline scritp as scm 
- give github url and jenkins file 
- now we can save and run the job "devops-demo-job"
- it will launch a new ec2 machine and deploy build also on nginx server (docker container)
- we will have to copy & save somewhere instance-id from console output of this job and use it for termination of created instance later after checking
- Create a another job named "terminate-ec2-job" as a freestyle project and use paramterized build with instance_id as a paramter which will be use to delete created instance from 1st job.
